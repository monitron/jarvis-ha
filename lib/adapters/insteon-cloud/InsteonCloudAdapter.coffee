
_ = require('underscore')
InsteonAPI = require('insteon-api')
Adapter = require('../../Adapter')
InsteonDimmerNode = require('./InsteonDimmerNode')
InsteonSwitchNode = require('./InsteonSwitchNode')
InsteonFanNode = require('./InsteonFanNode')

module.exports = class InsteonAdapter extends Adapter
  name: "Insteon Cloud"
  defaults:
    initialStatusCheck:   true # Check status on all devices upon connection?
    statusCheckInterval:  900  # Time between automatic status refreshes
                               # in seconds. Set null to disable.
    streamCycleInterval:  600  # How long (s) after receiving a message to close
                               # and reopen the stream to ensure it is working.
                               # Set null to disable.
    batchCommandInterval: 2000 # How long to wait between repeated commands (ms)
    proxyDevices:         {}   # Set "deviceId1": "deviceId2" to redirect all
                               # status messages from the key device to the
                               # value device. Also excludes the key device from
                               # bulk status checks. Useful for controllers.

  initialize: ->
    super
    @setValid false
    @hasDiscovered = false

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
      @_resetStreamCycle()
    @_api.on 'error', (e) => @log 'warn', "An Insteon error occurred: #{e}"
    @_api.on 'command', (cmd) => @_handleCommandReceived(cmd)

  discoverDevices: ->
    @_api.house().then (houses) => @_house = houses[0]
    #@_api.scene().then (scenes) =>
    #  console.log JSON.stringify(scenes)
    @_api.device().then (devices) =>
      @_devices = devices
      for device in devices
        nodeClass = switch device.devCat
          when 1
            switch device.subCat
              when 46 then InsteonFanNode
              else InsteonDimmerNode
          when 2 then InsteonSwitchNode
        if nodeClass?
          @log 'verbose', "Device ID #{device.id} (#{device.name}) enumerated"
          node = new nodeClass({id: device.id, hardwareID: device.insteonID},
            {adapter: this})
          @children.add node
        else
          @log 'warn', "Device ID #{device.id} has unknown category " +
            "#{device.devCat} subcategory #{device.subCat}"
      @hasDiscovered = true
      @setValid true
      if @get('initialStatusCheck') then @requestAllDevicesStatus()
      scInterval = @get('statusCheckInterval')
      if scInterval?
        @log 'debug', "Will check all device status at #{scInterval}s interval"
        @_statusCheck = setInterval(
          _.bind(@requestAllDevicesStatus, this), scInterval * 1000)

  requestAllDevicesStatus: ->
    # TODO don't request status on devices that won't reply (e.g. leak sensors)
    proxies = _.keys(@get('proxyDevices'))
    devices = @children.reject (child) => _.contains(proxies, child.id)
    interval = @get('batchCommandInterval')
    @log 'debug', "Requesting status of #{devices.length} devices " +
      "over the course of #{(interval * devices.length) / 1000} seconds"
    for device, i in devices
      setTimeout _.bind(@requestDeviceStatus, this, device), interval * i

  requestDeviceStatus: (device) ->
    # TODO notice when they don't respond
    switch device.interfaceType
      when 'light'
        @requestLightStatus device
      when 'fanlinc'
        @requestLightStatus device
        @requestFanStatus device
      else
        @log 'warn', "Unknown interface type for device #{device.id}"

  requestFanStatus: (device) ->
    @log 'verbose', "Requesting status for fan #{device.id}"
    @sendCommand(device.id, 'get_fan_speed').then (response) =>
      @log 'verbose', "Received fan status: #{JSON.stringify(response)}"
      device.processData {speed: response.speed}

  requestLightStatus: (device) ->
    light = @_api.light(device.id)
    @log 'verbose', "Requesting status for light #{device.id}"
    light.command('get_status').then (response) =>
      @log 'verbose', "Received light status: #{JSON.stringify(response)}"
      power = response.level == 0
      if device.hasAspect('brightness')
        device.processData {brightness: response.level}
      else
        device.processData {power: response.level != 0}

  toggleLight: (deviceId, value) ->
    light = @_api.light(deviceId)
    if value then light.turnOn(100) else light.turnOff() # Gives a promise

  setLightLevel: (deviceId, value) ->
    light = @_api.light(deviceId)
    if value == 0 then light.turnOff() else light.turnOn(value) # Gives a promise

  sendCommand: (deviceId, command, params = {}) ->
    baseCommand =
      device_id: deviceId
      command:   command
    @_api.command _.extend(baseCommand, params) # Returns a promise

  _handleCommandReceived: (cmd) ->
    @log 'verbose', "Received Insteon command: #{JSON.stringify(cmd)}"
    @_resetStreamCycle()
    node = @children.find(hardwareID: cmd.device_insteon_id)
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
        when 'unknown'         then @requestLightStatus(node)
        else @log 'debug', "Received unknown status cmd: #{JSON.stringify(cmd)}"
    else
      @log 'debug', "Received message for unknown or unidentifiable Insteon " +
        "device ID #{cmd.device_insteon_id}"

  _resetStreamCycle: ->
    streamCycleInterval = @get('streamCycleInterval')
    if streamCycleInterval?
      if @_streamCycle? then clearTimeout(@_streamCycle)
      @_streamCycle = setTimeout((=> @_cycleStream()),
        @get('streamCycleInterval') * 1000)

  _cycleStream: ->
    @_resetStreamCycle()
    @log 'verbose', "Stream has been inactive; cycling it"
    _.values(@_api.monitoring)[0].stream.close()
    @_api.monitor @_house