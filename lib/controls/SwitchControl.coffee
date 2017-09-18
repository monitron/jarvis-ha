[Control] = require('../Control')

module.exports = class SwitchControl extends Control
  commands:
    turnOff: (control, params) ->
      target = control.getConnectionTarget('powerOnOff')
      target.getAspect('powerOnOff').executeCommand 'set', false
    turnOn: (control, params) ->
      target = control.getConnectionTarget('powerOnOff')
      target.getAspect('powerOnOff').executeCommand 'set', true
    togglePower: (control, params) ->
      # Turns off if on. Turns on if off or undefined
      aspect = control.getConnectionTarget('powerOnOff').getAspect('powerOnOff')
      aspect.executeCommand 'set', !aspect.getDatum('state')

  _isActive: ->
    @getConnectionTarget('powerOnOff').getAspect('powerOnOff').getDatum('state')

  _getState: ->
    power = @getConnectionTarget('powerOnOff').getAspect('powerOnOff')
    power: power.getDatum('state')

  describeState: (state) ->
    if state.power == true
      'On'
    else if state.power == false
      'Off'
    else
      'not reporting status'

  describeStateTransition: (before, after) ->
    return null unless before.power? and after.power?
    if after.power then 'was turned on' else 'was turned off'
