[Control] = require('../Control')

module.exports = class SwitchControl extends Control
  commands:
    turnOff: (control, params) ->
      target = control.getConnectionTarget('powerOnOff')
      target.getAspect('powerOnOff').executeCommand 'set', false
    turnOn: (control, params) ->
      target = control.getConnectionTarget('powerOnOff')
      target.getAspect('powerOnOff').executeCommand 'set', true

  getState: ->
    power = @getConnectionTarget('powerOnOff').getAspect('powerOnOff')
    power: power.getDatum('state')
