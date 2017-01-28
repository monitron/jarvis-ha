
moment = require('moment')
crypto = require('crypto')
[AdapterNode] = require('../../AdapterNode')

# weatherAlerts significance and phenomenon explanations:
# http://www.nws.noaa.gov/os/vtec/pdfs/VTEC_explanation6.pdf

module.exports = class WeatherUndergroundStationNode extends AdapterNode
  aspects:
    temperatureSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    humiditySensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    weatherConditionSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    dayNightSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    ultravioletIndexSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    apparentTemperatureSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    windSpeedSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    windDirectionSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    dewpointSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    barometricPressureSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    weatherAlerts:
      events:
        changed: (prev, cur) -> prev.alerts != cur.alerts
    hourlyForecast:
      events:
        changed: (prev, cur) -> prev.alerts != cur.hours
    dailyForecast:
      events:
        changed: (prev, cur) -> prev.alerts != cur.hours

  conditionMap:
    'clear': 'clear'
    'chanceflurries': 'lightSnow'
    'chancerain': 'rain'
    'chancesleet': 'sleet'
    'chancesnow': 'snow'
    'chancetstorms': 'thunderstorm'
    'flurries': 'lightSnow'
    'fog': 'fog'
    'hazy': 'haze'
    'cloudy': 'cloudy'              #  |
    'mostlycloudy': 'mostlyCloudy'  #  |
    'partlycloudy': 'partlyCloudy'  #  |
    'partlysunny': 'partlySunny'    #  |
    'mostlysunny': 'mostlySunny'    #  |
    'sunny': 'clear'                # \|/
    'sleet': 'sleet'
    'rain': 'rain'
    'snow': 'snow'
    'tstorms': 'thunderstorm'
    'unknown': null

  alertSignificanceMap:
    'W': 'warning'
    'A': 'watch'
    'Y': 'advisory'
    'S': 'statement'
    'F': 'forecast'
    'O': 'outlook'
    'N': 'synopsis'

  processData: (data) ->
    console.log data
    @_processConditions data.current_observation
    @_processAstronomy data.moon_phase
    @_processAlerts data.alerts
    @_processHourlyForecast data.hourly_forecast
    @_processDailyForecast data.forecast

  _processConditions: (conditions) ->
    return unless conditions?
    @getAspect('temperatureSensor').setData
      value: conditions.temp_c
    @getAspect('humiditySensor').setData
      value: parseInt(conditions.relative_humidity) # "45%"
    @getAspect('weatherConditionSensor').setData
      value: @conditionMap[conditions.icon]
    @getAspect('apparentTemperatureSensor').setData
      value: Number(conditions.feelslike_c)
    @getAspect('ultravioletIndexSensor').setData
      value: Number(conditions.UV)
    @getAspect('windSpeedSensor').setData
      value: conditions.wind_kph
    @getAspect('windDirectionSensor').setData
      value: conditions.wind_degrees
    @getAspect('dewpointSensor').setData
      value: conditions.dewpoint_c
    @getAspect('barometricPressureSensor').setData
      value: Number(conditions.pressure_mb)

  _processAstronomy: (astronomy) ->
    return unless astronomy?
    sunrise = [Number(astronomy.sunrise.hour),
               Number(astronomy.sunrise.minute)]
    sunset  = [Number(astronomy.sunset.hour),
               Number(astronomy.sunset.minute)]
    now     = [Number(astronomy.current_time.hour),
               Number(astronomy.current_time.minute)]
    afterSunrise = (now[0] > sunrise[0]) or (now[0] == sunrise[0] and
      now[1] >= sunrise[1])
    beforeSunset = (now[0] < sunset[0]) or (now[0] == sunset[0] and
      now[1] <= sunset[1])
    @getAspect('dayNightSensor').setData
      value: afterSunrise and beforeSunset

  _processAlerts: (alerts) ->
    return unless alerts?
    @getAspect('weatherAlerts').setData alerts: for alert in alerts
      attributes =
        description:  alert.description
        start:        moment(alert.date_epoch, 'X').toDate()
        end:          moment(alert.expires_epoch, 'X').toDate()
        phenomenon:   alert.phenomena
        significance: @alertSignificanceMap[alert.significance]
      attributes.digest = crypto.createHash('md5')
        .update(JSON.stringify(attributes))
        .digest("hex")
      attributes.message = alert.message
      attributes

  _processHourlyForecast: (hours) ->
    return unless hours?
    @getAspect('hourlyForecast').setData hours: for hour in hours
      hour: Number(hour.FCTTIME.hour)
      time: moment(hour.FCTTIME.epoch, 'X').toDate()
      condition: @conditionMap[hour.icon]
      temperature: Number(hour.temp.metric)
      humidity: Number(hour.humidity)
      feelsLike: Number(hour.feelslike.metric)
      pop: Number(hour.pop)
      windSpeed: Number(hour.wspd.metric)
      windDirection: Number(hour.wdir.degrees)

  _processDailyForecast: (forecast) ->
    return unless forecast?
    days = forecast.simpleforecast.forecastday
    @getAspect('dailyForecast').setData days: for day in days
      year: day.date.year
      month: day.date.month
      day: day.date.day
      time: moment(day.date.epoch, 'X').toDate()
      highTemperature: Number(day.high.celsius)
      lowTemperature: Number(day.low.celsius)
      condition: @conditionMap[day.icon]
      pop: Number(day.pop)
