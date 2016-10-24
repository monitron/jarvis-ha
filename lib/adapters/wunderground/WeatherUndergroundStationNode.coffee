
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

  processData: (data) ->
    conditions = data.current_observation
    if conditions?
      @getAspect('temperatureSensor').setData
        value: conditions.temp_c
      @getAspect('humiditySensor').setData
        value: parseInt(conditions.relative_humidity) # "45%"
      @getAspect('weatherConditionSensor').setData
        value: @conditionMap[conditions.icon]
    astronomy = data.moon_phase
    if astronomy?
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
