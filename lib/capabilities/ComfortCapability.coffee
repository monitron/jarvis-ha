_ = require('underscore')
[Capability] = require('../Capability')

module.exports = class ComfortCapability extends Capability
  name: "Comfort"

  defaults:
    zones: {}
    temperaturePrecision: 1
    temperatureUnits: 'c'
    humidityPrecision: 0

  start: ->
    # Listen to sensors and thermostats
    for zone in _.values(@get('zones'))
      # Thermostat
      if zone.thermostatPath?
        @_server.adapters.onEventAtPath zone.thermostatPath,
          'aspectData:change', => @trigger 'change', this
      # Sensors
      for room in _.values(zone.rooms)
        for sensor in room.sensors
          @_server.adapters.onEventAtPath sensor.path,
            'aspectData:change', => @trigger 'change', this
    @setValid true # XXX Notice if source adapter becomes invalid

  zoneState: (zoneId) ->
    rooms = {}
    zone = @get('zones')[zoneId]
    for room, roomDetails of zone.rooms
      sensorValues = {}
      for sensor in roomDetails.sensors or []
        node = @_server.adapters.getPath(sensor.path)
        if node?
          for aspectName in sensor.aspects
            aspect = node.getAspect(aspectName)
            if aspect? then sensorValues[aspectName] = aspect.getDatum('value')
      rooms[room] = sensorValues
    thermostat = {}
    if zone.thermostatPath?
      node = @_server.adapters.getPath(zone.thermostatPath)
      if node?
        for aspectName in ['temperatureSensor', 'humiditySensor']
          thermostat[aspectName] = node.getAspect(aspectName)?.getDatum('value')
    sensors: rooms, thermostat: thermostat

  _getState: ->
    _.object(for zone in _.keys(@get('zones'))
      [zone, @zoneState(zone)])
