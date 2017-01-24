
moment = require('moment')
crypto = require('crypto')
[AdapterNode] = require('../../AdapterNode')

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
    weatherAlertsSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value

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

  _processConditions: (conditions) ->
    return unless conditions?
    @getAspect('temperatureSensor').setData
      value: conditions.temp_c
    @getAspect('humiditySensor').setData
      value: parseInt(conditions.relative_humidity) # "45%"
    @getAspect('weatherConditionSensor').setData
      value: @conditionMap[conditions.icon]

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
    @getAspect('weatherAlertsSensor').setData values: for alert in alerts
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
