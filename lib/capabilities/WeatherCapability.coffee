_ = require('underscore')
[Capability] = require('../Capability')

module.exports = class WeatherCapability extends Capability
  name: "Weather"

  defaults:
    sources: []
    temperatureUnits: 'c'
    temperaturePrecision: 0
    humidityPrecision: 0

  start: ->
    # Notice when source data changes
    for source in @get('sources')
      @_server.adapters.onEventAtPath source.path,
        'aspectData:change', => @trigger 'change', this
    @setValid true # XXX Notice if source adapter becomes invalid

  getSourceAspect: (aspect) ->
    source = _.find(@get('sources'), (s) -> _.contains(s.aspects, aspect))
    return undefined unless source?
    @_server.adapters.getPath(source.path)?.getAspect(aspect)

  summarizeConditions: ->
    data = {}
    aspect = @getSourceAspect('temperatureSensor')
    if aspect? then data.temperature = aspect.getDatum('value')
    aspect = @getSourceAspect('humiditySensor')
    if aspect? then data.humidity = aspect.getDatum('value')
    aspect = @getSourceAspect('weatherConditionSensor')
    if aspect? then data.condition = aspect.getDatum('value')
    aspect = @getSourceAspect('dayNightSensor')
    if aspect? then data.isDay = aspect.getDatum('value')
    aspect = @getSourceAspect('stillCamera')
    if aspect? then data.imageLocation = aspect.getDatum('imageLocation')
    data

  _getState: ->
    conditions: @summarizeConditions()
