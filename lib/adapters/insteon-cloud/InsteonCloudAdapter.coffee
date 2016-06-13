
_ = require('underscore')
InsteonAPI = require('insteon-api')
Adapter = require('../../Adapter')
InsteonDimmerNode = require('./InsteonDimmerNode')
InsteonSwitchNode = require('./InsteonSwitchNode')

module.exports = class InsteonAdapter extends Adapter
  name: "Insteon Cloud"
  defaults:
    initialStatusCheck:   true # Check status on all devices upon connection?
    batchCommandInterval: 2000 # How long to wait between repeated commands (ms)
    proxyDevices:         {}   # Set "deviceId1": "deviceId2" to redirect all
                               # status messages from the key device to the
                               # value device. Also excludes the key device from
                               # bulk status checks. Useful for controllers.

  initialize: ->
    super
    @setValid false
    @hasDiscovered = false
    @_nodesByHexId = {}
    @_nodesById = {}

  start: ->
    @_api = new InsteonAPI(key: @get('apiKey'))
    @log "debug", "Authenticating to Insteon API with username #{@get('username')}"
    @_api.connect username: @get('username'), password: @get('password')
    @_api.on 'connect', =>
      @log 'debug', 'Authenticated to Insteon API'
      if @hasDiscovered
        @setValid true
      else
        @discoverDevices()
    @_api.on 'error', (e) => @log 'warn', "An Insteon error occurred: #{e}"
    @_api.on 'command', (cmd) => @_handleCommandReceived(cmd)

  discoverDevices: ->
    @_api.device().then (devices) =>
      @_devices = devices
      for device in devices
        nodeClass = switch device.devCat
          when 1 then InsteonDimmerNode
          when 2 then InsteonSwitchNode
        if nodeClass?
          @log 'verbose', "Device ID #{device.id} (#{device.name}) enumerated"
          node = new nodeClass({id: device.id}, {adapter: this})
          @children.add node
          @_nodesByHexId[device.insteonID] = node
          @_nodesById[device.id] = node
        else
          @log 'warn', "Device ID #{device.id} has unknown category " +
            "#{device.devCat}"
      @hasDiscovered = true
      @setValid true
      if @get('initialStatusCheck') then @requestAllDevicesStatus()

  requestAllDevicesStatus: ->
    ids = _.without(_.keys(@_nodesById), _.keys(@get('proxyDevices'))...)
    interval = @get('batchCommandInterval')
    @log 'debug', "Requesting status of #{ids.length} devices " +
      "over the course of #{(interval * ids.length) / 1000} seconds"
    for deviceId, i in ids
      setTimeout _.bind(@requestDeviceStatus, this, deviceId), interval * i

  requestDeviceStatus: (deviceId) ->
    # Right now they're all lights...
    @requestLightStatus deviceId

  requestLightStatus: (deviceId) ->
    light = @_api.light(deviceId)
    @log 'verbose', "Requesting status for light #{deviceId}"
    light.command('get_status').then (response) =>
      @log 'verbose', "Received status: #{JSON.stringify(response)}"
      power = response.level == 0
      node = @children.get(deviceId)
      if node instanceof InsteonDimmerNode
        node.processData {brightness: response.level}
      else
        node.processData {power: response.level != 0}

  toggleLight: (deviceId, value) ->
    light = @_api.light(deviceId)
    if value then light.turnOn(100) else light.turnOff() # Gives a promise

  setLightLevel: (deviceId, value) ->
    light = @_api.light(deviceId)
    if value == 0 then light.turnOff() else light.turnOn(value) # Gives a promise

  _handleCommandReceived: (cmd) ->
    @log 'verbose', "Received Insteon command for device #{cmd.device_insteon_id}"
    node = @_nodesByHexId[cmd.device_insteon_id]
    proxyFor = @get('proxyDevices')[node.id]
    if proxyFor?
      node = @children.get(proxyFor)
      if node?
        @log 'verbose', "...proxied to #{node.id}"
      else
        @log 'warn', "Proxy target device #{proxyFor} does not exist!"
    if node?
      @log 'verbose', "Dispatching #{cmd.status} command to node #{node.id}"
      switch cmd.status
        when 'on',  'fast_on'  then node.processData(power: true)
        when 'off', 'fast_off' then node.processData(power: false)
        when 'unknown'         then @requestLightStatus(node.id)
        else @log 'debug', "Received unknown status cmd: #{JSON.stringify(cmd)}"
    else
      @log 'debug', "Received message for unknown or unidentifiable Insteon " +
        "device ID #{cmd.device_insteon_id}"
