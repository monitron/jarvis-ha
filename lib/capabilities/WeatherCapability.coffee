_ = require('underscore')
[Capability] = require('../Capability')

module.exports = class WeatherCapability extends Capability
  name: "Weather"

  defaults:
    temperatureUnits: 'c'
    temperaturePrecision: 0
    humidityPrecision: 0

  start: ->
    conditions = @conditionsSourceNode()
    if conditions?
      # Notice when source data changes
      @_server.adapters.onEventAtPath @get('conditionsSource'),
        'aspectData:change', => @trigger 'change', this
    else
      @log 'error', 'conditionsSource not specified or missing'
    @setValid true # XXX Notice if source adapter becomes invalid

  conditionsSourceNode: ->
    return undefined unless @has('conditionsSource')
    @_server.adapters.getPath(@get('conditionsSource'))

  summarizeConditions: ->
    data = {}
    node = @conditionsSourceNode()
    if node.hasAspect('temperatureSensor')
      data.temperature = node.getAspect('temperatureSensor').getDatum('value')
    if node.hasAspect('humiditySensor')
      data.humidity = node.getAspect('humiditySensor').getDatum('value')
    if node.hasAspect('weatherConditionSensor')
      data.condition = node.getAspect('weatherConditionSensor').getDatum('value')
    if node.hasAspect('dayNightSensor')
      data.isDay = node.getAspect('dayNightSensor').getDatum('value')
    data

  toJSON: ->
    _.extend super,
      conditions: @summarizeConditions()