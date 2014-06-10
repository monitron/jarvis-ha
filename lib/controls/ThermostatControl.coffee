[Control] = require('../Control')

module.exports = class ThermostatControl extends Control
  getState: ->
    temp = @getConnectionTarget('temperatureSensor').
      getAspect('temperatureSensor')
    setPoint = @getConnectionTarget('temperatureSetPoint').
      getAspect('temperatureSetPoint')
    humid = @getConnectionTarget('humiditySensor')?.getAspect('humiditySensor')
    currentTemperature: temp.getDatum('value')
    currentHumidity: humid?.getDatum('value')
    mode: setPoint.getDatum('mode')
    targetTemperature: setPoint.getDatum('target')
