_ = require('underscore')
[Capability] = require('../Capability')

# cameraRefreshInterval:
# Set to a time in seconds if the camera URL never changes and you wish it
# to be periodically refreshed (with a random query string to avoid cache)

# alertEvents:
# Maps weather alert significance to event importance. Alerts whose significance
# doesn't appear in this map will not result in an event. Leave empty ({}) if
# you don't want any events being created based on weather alerts.

module.exports = class WeatherCapability extends Capability
  name: "Weather"

  defaults:
    sources: []
    temperatureUnits: 'c'
    temperaturePrecision: 0
    humidityPrecision: 0
    precipitationPrecision: 2
    precipitationUnits: 'in' # or mm
    speedUnits: 'kph'
    pressureUnits: 'mbar'
    pressurePrecision: 0
    cameraRefreshInterval: null
    alertEvents:
      warning: 'low'
      watch: 'low'

  start: ->
    # Notice when source data changes
    for source in @get('sources')
      @_server.adapters.onEventAtPath source.path,
        'aspectData:change', => @trigger 'change', this

    # When weather alerts change, update our events
    alertsPath = @getSourcePath('weatherAlerts')
    if alertsPath?
      @_server.adapters.onEventAtPath alertsPath,
        'aspectData:change', => @updateAlertEvents()
      @updateAlertEvents() # Do it once immediately

    @setValid true # XXX Notice if source adapter becomes invalid

  getSourceAspect: (aspect) ->
    path = @getSourcePath(aspect)
    return undefined unless path?
    @_server.adapters.getPath(path)?.getAspect(aspect)

  getSourcePath: (aspect) ->
    source = _.find(@get('sources'), (s) -> _.contains(s.aspects, aspect))
    return undefined unless source?
    source.path

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
    aspect = @getSourceAspect('precipitationQuantitySensor')
    if aspect?
      data['precipitationQuantity24Hour'] = aspect.getDatum('24hour')
      data['precipitationQuantityToday'] = aspect.getDatum('today')
    for aspectName in ['humidity', 'temperature', 'barometricPressure',
      'dewpoint', 'windDirection', 'windSpeed', 'ultravioletIndex',
      'apparentTemperature', 'windGustSpeed', 'precipitationRate']
      aspect = @getSourceAspect(aspectName + 'Sensor')
      if aspect? then data[aspectName] = aspect.getDatum('value')
    data

  updateAlertEvents: ->
    aspect = @getSourceAspect('weatherAlerts')
    alerts = aspect?.getDatum('alerts') or []
    ongoing = @ongoingEvents()
    # End ongoing events that no longer have an alert
    for event in ongoing
      unless _.findWhere(alerts, digest: event.get('reference'))?
        @log 'debug', "Ending alert event #{event.get('reference')}"
        event.set end: new Date()
    # Create events for new alerts
    for alert in alerts
      unless _.find(ongoing, (event) -> event.get('reference') == alert.digest)
        importance = @get('alertEvents')[alert.significance]
        if importance?
          @log 'debug', "Creating alert event #{alert.digest}"
          @createEvent
            importance: importance
            title: alert.description
            reference: alert.digest

  _getState: ->
    conditions: @summarizeConditions()
