crypto = require('crypto')
moment = require('moment')
[AdapterNode] = require('../../AdapterNode')

module.exports = class DarkSkyLocationNode extends AdapterNode
  aspects:
    temperatureSensor: {}
    humiditySensor: {}
    weatherConditionSensor: {}
    dayNightSensor: {}
    ultravioletIndexSensor: {}
    apparentTemperatureSensor: {}
    windSpeedSensor: {}
    windDirectionSensor: {}
    dewpointSensor: {}
    barometricPressureSensor: {}
    weatherAlerts: {}
    hourlyForecast: {}
    dailyForecast: {}
    minutelyForecastNarrative: {}
    hourlyForecastNarrative: {}
    dailyForecastNarrative: {}

  conditionMap:
    'clear-day': 'clear'
    'clear-night': 'clear'
    'rain': 'rain'
    'snow': 'snow'
    'sleet': 'sleet'
    'wind': 'wind'
    'fog': 'fog'
    'cloudy': 'cloudy'
    'partly-cloudy-day': 'partlyCloudy'
    'partly-cloudy-night': 'partlyCloudy'

  initialize: ->
    super
    setInterval (=> @fetch()), @get('interval') * 1000
    @fetch() # initial fetch

  fetch: ->
    @log 'verbose', 'Fetching...'
    promise = @adapter.api
      .latitude(@get('location')[0])
      .longitude(@get('location')[1])
      .units('ca')
      .language('en')
      .get()

    promise.then(
      (result) =>
        @processCurrently result.currently
        @processDayNight  result
        @processAlerts    result.alerts
        @processHourly    result.hourly.data, (hour) =>
          @isDaylightHour(result.daily.data, hour)
        @processDaily     result.daily.data
        @setValid true,
      (err) =>
        @log 'warn', "Quantitative fetch request failed (#{err})"
        @setValid false
    )      

    # Also narratives
    promise = @adapter.api
      .latitude(@get('location')[0])
      .longitude(@get('location')[1])
      .units(@get('narrativeUnits'))
      .language(@get('narrativeLanguage'))
      .get()

    promise.then(
      (result) =>
        @processNarratives result
        @setValid true,
      (err) =>
        @log 'warn', "Narrative fetch request failed (#{err})"
        @setValid false
    )

  processNarratives: (result) ->
    @getAspect('dailyForecastNarrative').setData text: result.daily.summary
    @getAspect('hourlyForecastNarrative').setData text: result.hourly.summary
    @getAspect('minutelyForecastNarrative').setData text: result.minutely.summary

  processCurrently: (currently) ->
    toSet =
      temperatureSensor:         currently.temperature
      humiditySensor:            currently.humidity * 100
      apparentTemperatureSensor: currently.apparentTemperature
      dewpointSensor:            currently.dewPoint
      windSpeedSensor:           currently.windSpeed
      windDirectionSensor:       currently.windBearing
      ultravioletIndexSensor:    currently.uvIndex
      barometricPressureSensor:  currently.pressure
      weatherConditionSensor:    @conditionMap[currently.icon] || null
    for aspectName, value of toSet
      @getAspect(aspectName).setData value: value

  processDayNight: (result) ->
    now = result.currently.time
    today = result.daily.data[0]
    @getAspect('dayNightSensor').setData
      value: now >= today.sunriseTime and now <= today.sunsetTime

  processAlerts: (alerts) ->
    processedAlerts = []
    if alerts? # alerts not present == no alerts
      processedAlerts = for alert in alerts
        attributes =
          description:  alert.title
          start:        moment(alert.time, 'X').toDate()
          end:          moment(alert.expires, 'X').toDate()
          significance: alert.severity # advisory, watch or warning
        attributes.digest = crypto.createHash('md5')
          .update(JSON.stringify(attributes))
          .digest("hex")
        attributes.message = alert.description
        attributes
    @getAspect('weatherAlerts').setData alerts: processedAlerts

  processHourly: (hourly, isDaylightHour) ->
    @getAspect('hourlyForecast').setData hours: for hour in hourly
      hourMoment = moment(hour.time, 'X')
      time: hourMoment.toDate()
      condition: @conditionMap[hour.icon]
      temperature: hour.temperature
      humidity: hour.humidity * 100
      apparentTemperature: hour.apparentTemperature
      pop: hour.precipProbability * 100
      windSpeed: hour.windSpeed
      windDirection: hour.windBearing
      dayNight: isDaylightHour(hourMoment)

  processDaily: (daily) ->
    @getAspect('dailyForecast').setData days: for day in daily
      time: moment(day.time, 'X').toDate()
      highTemperature: day.temperatureHigh
      lowTemperature: day.temperatureLow
      condition: @conditionMap[day.icon]
      pop: day.precipProbability * 100
      windSpeed: day.windSpeed
      windDirection: day.windBearing

  isDaylightHour: (days, hourMoment) ->
    time = hourMoment.add(30, 'minutes').unix()
    for day in days
      if time >= day.sunriseTime and time <= day.sunsetTime then return true
    false
