_ = require('underscore')
geolib = require('geolib')
[Capability] = require('../../Capability')

module.exports = class VehiclesCapability extends Capability
  name: "Vehicles"

  sensorAspectNames: [
    'batteryLevelSensor',
    'chargingStatusSensor',
    'vehicleRangeSensor',
    'chargingTimeRemainingSensor',
    'vehicleStatusSensor',
    'locationSensor'
  ]

  # Vehicles have: name, source
  defaults:
    vehicles: {}
    home: {} # lat, lng, radius (in meters)
    distanceUnits: 'km'
    distancePrecision: 0

  start: ->
    _.each @get('vehicles'), (vehicle, id) =>
      @_server.adapters.onEventAtPath vehicle.path,
        'aspectData:change', => @trigger 'change', this
    @setValid true

  vehicleState: (id) ->
    config = @get('vehicles')[id]
    node = @_server.adapters.getPath(config.path)
    result = name: config.name
    if node?
      sensorValues = {}
      asOf = null
      for aspectName in @sensorAspectNames
        if node.hasAspect(aspectName)
          data = node.getAspect(aspectName).getData()
          asOf ||= data.asOf
          sensorValues[aspectName] = data.value
      distanceFromHome = @distanceFromHome(sensorValues['locationSensor'])
      if distanceFromHome?
        isHome = distanceFromHome <= @get('home').radius
      else
        isHome = null
      Object.assign(result, {
        sensorValues: sensorValues
        distanceFromHome: distanceFromHome / 1000 # m to km
        isHome: isHome
        asOf: asOf
        status: @combinedVehicleStatus(sensorValues.chargingStatusSensor,
          sensorValues.vehicleStatusSensor)
      })
    result

  combinedVehicleStatus: (chargingStatus, vehicleStatus) ->
    if chargingStatus?
      if chargingStatus == 'disconnected'
        vehicleStatus or 'unknown'
      else chargingStatus
    else if vehicleStatus?
      vehicleStatus
    else 'unknown'

  distanceFromHome: (location) ->
    home = @get('home')
    return null unless location? and location.lat? and home.lat?
    geolib.getDistance(
      {latitude: location.lat, longitude: location.lng},
      {latitude: home.lat, longitude: location.lng})

  _getState: ->
    vehicles: _.object(for vehicle in _.keys(@get('vehicles'))
      [vehicle, @vehicleState(vehicle)])