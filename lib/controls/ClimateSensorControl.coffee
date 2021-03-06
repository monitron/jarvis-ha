[Control] = require('../Control')

module.exports = class ClimateSensorControl extends Control
  defaultParameters:
    temperatureUnits: 'c'
    temperaturePrecision: 1
    humidityPrecision: 0

  _getState: ->
    temp  = @getConnectionTarget('temperatureSensor')
    humid = @getConnectionTarget('humiditySensor')
    cond  = @getConnectionTarget('weatherConditionSensor')
    day   = @getConnectionTarget('dayNightSensor')
    temperature: temp?.getAspect('temperatureSensor').getDatum('value')
    humidity:    humid?.getAspect('humiditySensor').getDatum('value')
    condition:   cond?.getAspect('weatherConditionSensor').getDatum('value')
    daytime:     day?.getAspect('dayNightSensor').getDatum('value')
