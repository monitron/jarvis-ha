[Control] = require('../Control')

module.exports = class ClimateSensorControl extends Control
  defaultParameters:
    temperatureUnits: 'c'
    temperaturePrecision: 1
    humidityPrecision: 0

  _getState: ->
    temp = @getConnectionTarget('temperatureSensor')
    humid = @getConnectionTarget('humiditySensor')
    temperature: temp?.getAspect('temperatureSensor').getDatum('value')
    humidity: humid?.getAspect('humiditySensor').getDatum('value')
