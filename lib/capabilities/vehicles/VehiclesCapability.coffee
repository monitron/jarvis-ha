_ = require('underscore')
#geolib = require('geolib')
[Capability] = require('../../Capability')
[Consumption, Consumptions] = require('../../Consumption')

module.exports = class VehiclesCapability extends Capability
  name: "Vehicles"

  sensorAspectNames: [
    'batteryLevelSensor',
    'chargingStatusSensor',
    'vehicleRangeSensor',
    'chargingTimeRemainingSensor',
    'vehicleStatusSensor',
    'locationSensor',
    'chargingPowerSensor'
  ]

  # Vehicles have: name, source
  defaults:
    vehicles: {}
    home: {} # lat, lng, radius (in meters)
    distanceUnits: 'km'
    distancePrecision: 0
    onlyConsumeAtHome: true

  start: ->
    notifyChangeSoon = _.debounce(=>
      @trigger 'change', this
      @trigger 'consumption:change', this)
    _.each @get('vehicles'), (vehicle, id) =>
      @_server.adapters.onEventAtPath vehicle.path,
        'aspectData:change', notifyChangeSoon
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

  isHome: (distance) ->
    if distance? then distance <= @get('home').radius else null

  distanceFromHome: (location) ->
    home = @get('home')
    return null #unless location? and location.lat? and home.lat?
#    geolib.getDistance(
#      {latitude: location.lat, longitude: location.lng},
#      {latitude: home.lat, longitude: location.lng})

  getResourceConsumption: ->
    consumptions = new Consumptions()
    onlyConsumeAtHome = @get('onlyConsumeAtHome')
    for id, config of @get('vehicles')
      node = @_server.adapters.getPath(config.path)
      if node?.hasAspect('chargingPowerSensor')
        power = node.getAspect('chargingPowerSensor').getData().value
        canConsume = true
        if onlyConsumeAtHome
          canConsume = @isHome(@distanceFromHome(
            node.getAspect('locationSensor').getData().value))
        if canConsume and power > 0 then consumptions.add
          capabilityId: @id
          node: id
          name: config.name
          category: 'Vehicles'
          resourceType: 'electricity'
          rate: power
    consumptions


  _getState: ->
    vehicles: _.object(for vehicle in _.keys(@get('vehicles'))
      [vehicle, @vehicleState(vehicle)])