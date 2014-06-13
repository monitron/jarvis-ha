[Control] = require('../Control')

module.exports = class ThermostatControl extends Control
  getState: ->
    setPoint = @getConnectionTarget('temperatureSetPoint').
      getAspect('temperatureSetPoint')
    mode: setPoint.getDatum('mode')
    targetTemperature: setPoint.getDatum('target')
