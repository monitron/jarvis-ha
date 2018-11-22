_ = require('underscore')
[Capability] = require('../../Capability')

module.exports = class VehiclesCapability extends Capability
  name: "Vehicles"

  sensorAspectNames: [
    'batteryLevelSensor',
    'chargingStatusSensor',
    'vehicleRangeSensor'
  ]

  # Vehicles have: name, source
  defaults:
    vehicles: {}

  start: ->
    _.each @get('vehicles'), (vehicle, id) =>
      @_server.adapters.onEventAtPath vehicle.path,
        'aspectData:change', => @trigger 'change', this
    @setValid true

  vehicleState: (id) ->
    config = @get('vehicles')[id]
    node = @_server.adapters.getPath(config.path)
    sensorValues = {}
    asOf = null
    for aspectName in @sensorAspectNames
      if node.hasAspect(aspectName)
        data = node.getAspect(aspectName).getData()
        asOf ||= data.asOf
        sensorValues[aspectName] = data.value
    name: config.name
    sensorValues: sensorValues
    asOf: asOf

  _getState: ->
    vehicles: _.object(for vehicle in _.keys(@get('vehicles'))
      [vehicle, @vehicleState(vehicle)])