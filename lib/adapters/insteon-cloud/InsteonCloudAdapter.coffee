
_ = require('underscore')
InsteonAPI = require('insteon-api')
Adapter = require('../../Adapter')
InsteonDimmerNode = require('./InsteonDimmerNode')
InsteonSwitchNode = require('./InsteonSwitchNode')

module.exports = class InsteonAdapter extends Adapter
  name: "Insteon"

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
    @_api.on 'error', =>
      @log 'warn', 'An Insteon error occurred'
    @_api.on 'command', (message) =>
      raw = message.standard?.raw
      @log "verbose", "Received Insteon message: #{raw}"

  discoverDevices: ->
    @_api.device().then (devices) =>
      for device in devices
        nodeClass = switch device.devCat
          when 1 then InsteonDimmerNode
          when 2 then InsteonSwitchNode
        if nodeClass?
          @log 'debug', "Device ID #{device.id} (#{device.name}) enumerated"
          node = new nodeClass({id: device.id}, {adapter: this})
          @children.add node
        else
          @log 'warn', "Device ID #{device.id} has unknown category " +
            "#{device.devCat}"
      @hasDiscovered = true

  toggleLight: (deviceId, value) ->
    light = @_api.light(deviceId)
    if value then light.turnOn(100) else light.turnOff() # Gives a promise

  setLightLevel: (deviceId, value) ->
    light = @_api.light(deviceId)
    if value == 0 then light.turnOff() else light.turnOn(value) # Gives a promise

  observeLight: (node) ->
    @log 'verbose', "Observing light events on #{node.id}"
    light = @_hub.light(node.id)
    light.on 'turnOn',      -> node.processData(power: true)
    light.on 'turnOnFast',  -> node.processData(power: true)
    light.on 'turnOff',     -> node.processData(power: false)
    light.on 'turnOffFast', -> node.processData(power: false)