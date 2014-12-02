
_ = require('underscore')
Insteon = require('home-controller').Insteon
Adapter = require('../../Adapter')
InsteonDimmerNode = require('./InsteonDimmerNode')

module.exports = class InsteonAdapter extends Adapter
  name: "Insteon"
  defaults:
    gatewayPort: 9761

  initialize: ->
    super
    @setValid false
    @hasEnumerated = false

  start: ->
    @_hub = new Insteon()
    switch @get('gatewayType')
      when "hub"
        @log "debug", "Connecting to Insteon Hub at #{@get('gatewayHost')}"
        @_hub.connect @get('gatewayHost')
      when "serial"
        @log "debug", "Connecting to Insteon PLM on #{@get('serialPort')}"
        @_hub.serial @get('serialPort')
    @_hub.on 'connect', =>
      @log "debug", "Connected to Insteon"
      @setValid true
      unless @hasEnumerated then @enumerateDevices()
    @_hub.on 'closed', =>
      @log "warn", "Disconnected from Insteon"
      @setValid false
    @_hub.on 'command', (message) =>
      raw = message.standard?.raw
      @log "verbose", "Received Insteon message: #{raw}"

  enumerateDevices: ->
    for deviceId, i in @get('deviceIds')
      # Go slow so as not to flood the Insteon channel
      setTimeout _.bind(@enumerateDevice, this, deviceId), 1000 * i
    @hasDiscovered = true

  enumerateDevice: (deviceId) ->
    @log "debug", "Attempting to enumerate device ID #{deviceId}"
    @_hub.info(deviceId).done (deviceInfo) =>
      if deviceInfo?
        nodeClass = switch deviceInfo.deviceCategory.id
          when 1 then InsteonDimmerNode
        if nodeClass?
          @log "debug", "Successfully enumerated device with ID #{deviceInfo.id}"
          @children.add new nodeClass({id: deviceInfo.id}, {adapter: this})
        else
          @log "warn", "Device ID #{deviceInfo.id} has unknown category " +
            "#{deviceInfo.deviceCategory.id}"
      else
        @log "warn", "Failed to query device with ID #{deviceId}"

  toggleLight: (deviceId, value) ->
    light = @_hub.light(deviceId)
    if value then light.turnOn(100) else light.turnOff() # Gives a promise

  setLightLevel: (deviceId, value) ->
    light = @_hub.light(deviceId)
    if value == 0 then light.turnOff() else light.turnOn(value) # Gives a promise
