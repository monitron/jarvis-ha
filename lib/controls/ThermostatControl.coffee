[Control] = require('../Control')

module.exports = class ThermostatControl extends Control
  defaultParameters:
    temperatureUnits: 'c'
    temperaturePrecision: 0

  commands:
    setMode:
      execute: (control, params) ->
        target = control.getConnectionTarget('temperatureSetPoint')
        target.getAspect('temperatureSetPoint').executeCommand 'setMode',
          params.value
      wouldHaveEffect: (params, state) -> state.mode != params.value
    setTarget:
      execute: (control, params) ->
        target = control.getConnectionTarget('temperatureSetPoint')
        target.getAspect('temperatureSetPoint').executeCommand 'setTarget',
          parseFloat(params.value)
      wouldHaveEffect: (params, state) ->
        state.targetTemperature != parseFloat(params.value)

  _getState: ->
    setPoint = @getConnectionTarget('temperatureSetPoint').
      getAspect('temperatureSetPoint')
    mode: setPoint.getDatum('mode')
    targetTemperature: setPoint.getDatum('target')
    modeChoices: setPoint.getAttribute('modeChoices')
