
Adapter = require('../../Adapter')
Insteon = require('home-controller').Insteon
InsteonDimmerNode = require('./InsteonDimmerNode')

module.exports = class InsteonAdapter extends Adapter
  name: "Insteon"
  configDefaults:
    gatewayPort: 9761

  constructor: (config) ->
    super config
    @hasEnumerated = false
    @setValid false

  start: ->
    @_hub = new Insteon()
    @log "debug", "Attempting to connect to Insteon hub"
    @_hub.connect @config.gatewayHost
    @_hub.on 'connect', =>
      @log "debug", "Connected to Insteon hub"
      @setValid true
      unless @hasEnumerated then @enumerateDevices()
    @_hub.on 'closed', =>
      @log "warn", "Disconnected from Insteon hub"
      @setValid false
    @_hub.on 'command', (message) =>
      raw = message.standard?.raw
      @log "verbose", "Received Insteon message: #{raw}"

  enumerateDevices: ->
    for deviceId in @config.deviceIds
      @log "debug", "Attempting to enumerate device ID #{deviceId}"
      @_hub.info(deviceId).done (deviceInfo) =>
        if deviceInfo?
          nodeClass = switch deviceInfo.deviceCategory.id
            when 1 then InsteonDimmerNode
          if nodeClass?
            @log "debug", "Successfully enumerated device with ID #{deviceInfo.id}"
            @addChild new nodeClass(deviceInfo.id, this)
          else
            @log "warn", "Device ID #{deviceInfo.id} has unknown category " +
              "#{deviceInfo.deviceCategory.id}"
        else
          @log "warn", "Failed to query device with ID #{deviceInfo.id}"
    @hasDiscovered = true

  toggleLight: (deviceId, value) ->
    light = @_hub.light(deviceId)
    if value then light.turnOn(100) else light.turnOff() # Gives a promise

  setLightLevel: (deviceId, value) ->
    light = @_hub.light(deviceId)
    if value == 0 then light.turnOff() else light.turnOn(value) # Gives a promise
