
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
    'sunny': 'sunny'                # \|/
    'sleet': 'sleet'
    'rain': 'rain'
    'snow': 'snow'
    'tstorms': 'thunderstorm'
    'unknown': null

  processData: (data) ->
    conditions = data.current_observation
    if conditions?
      @getAspect("temperatureSensor").setData
        value: conditions.temp_c
      @getAspect("humiditySensor").setData
        value: parseInt(conditions.relative_humidity) # "45%"
      @getAspect("weatherConditionSensor").setData
        value: @conditionMap[conditions.icon]
