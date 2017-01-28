_ = require('underscore')
[Capability] = require('../Capability')

# cameraRefreshInterval:
# Set to a time in seconds if the camera URL never changes and you wish it
# to be periodically refreshed (with a random query string to avoid cache)

module.exports = class WeatherCapability extends Capability
  name: "Weather"

  defaults:
    sources: []
    temperatureUnits: 'c'
    temperaturePrecision: 0
    humidityPrecision: 0
    speedUnits: 'kph'
    pressureUnits: 'mbar'
    pressurePrecision: 0
    cameraRefreshInterval: null

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

    aspect = @getSourceAspect('weatherConditionSensor')
    if aspect? then data.condition = aspect.getDatum('value')
    aspect = @getSourceAspect('dayNightSensor')
    if aspect? then data.isDay = aspect.getDatum('value')
    aspect = @getSourceAspect('stillCamera')
    if aspect? then data.imageLocation = aspect.getDatum('imageLocation')
    aspect = @getSourceAspect('dailyForecast')
    if aspect? then data.forecastDays = aspect.getDatum('days')
    aspect = @getSourceAspect('hourlyForecast')
    if aspect? then data.forecastHours = aspect.getDatum('hours')
    aspect = @getSourceAspect('weatherAlerts')
    if aspect? then data.alerts = aspect.getDatum('alerts')
    for aspectName in ['humidity', 'temperature', 'barometricPressure',
      'dewpoint', 'windDirection', 'windSpeed', 'ultravioletIndex',
      'apparentTemperature']
      aspect = @getSourceAspect(aspectName + 'Sensor')
      if aspect? then data[aspectName] = aspect.getDatum('value')
    data

  _getState: ->
    conditions: @summarizeConditions()
