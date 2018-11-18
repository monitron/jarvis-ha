[Control] = require('../Control')

module.exports = class SwitchControl extends Control
  commands:
    turnOff:
      execute: (control, params) ->
        target = control.getConnectionTarget('powerOnOff')
        target.getAspect('powerOnOff').executeCommand 'set', false
      wouldHaveEffect: (params, state) -> state.power != false
    turnOn:
      execute: (control, params) ->
        target = control.getConnectionTarget('powerOnOff')
        target.getAspect('powerOnOff').executeCommand 'set', true
      wouldHaveEffect: (params, state) -> state.power != true
    togglePower: # Turns off if on. Turns on if off or undefined
      execute: (control, params) ->
        aspect = control.getConnectionTarget('powerOnOff').getAspect('powerOnOff')
        aspect.executeCommand 'set', !aspect.getDatum('state')
      wouldHaveEffect: -> true

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
