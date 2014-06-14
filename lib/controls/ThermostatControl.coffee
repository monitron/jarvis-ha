[Control] = require('../Control')

module.exports = class ThermostatControl extends Control
  defaultParameters:
    temperatureUnits: 'c'
    temperaturePrecision: 0

  commands:
    setMode: (control, params) ->
      target = control.getConnectionTarget('temperatureSetPoint')
      target.getAspect('temperatureSetPoint').executeCommand 'setMode',
        params.value
    setTarget: (control, params) ->
      target = control.getConnectionTarget('temperatureSetPoint')
      target.getAspect('temperatureSetPoint').executeCommand 'setTarget',
        parseFloat(params.value)

  getState: ->
    setPoint = @getConnectionTarget('temperatureSetPoint').
      getAspect('temperatureSetPoint')
    mode: setPoint.getDatum('mode')
    targetTemperature: setPoint.getDatum('target')
    modeChoices: setPoint.getAttribute('modeChoices')
