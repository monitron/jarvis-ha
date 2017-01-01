[Control] = require('../Control')

module.exports = class DimmerControl extends Control
  commands:
    turnOff: (control, params) ->
      target = control.getConnectionTarget('powerOnOff')
      target.getAspect('powerOnOff').executeCommand 'set', false
    turnOn: (control, params) ->
      target = control.getConnectionTarget('powerOnOff')
      target.getAspect('powerOnOff').executeCommand 'set', true
    setBrightness: (control, params) ->
      target = control.getConnectionTarget('brightness')
      target.getAspect('brightness').executeCommand 'set',
        parseInt(params.value)

  _isActive: ->
    @getConnectionTarget('powerOnOff').getAspect('powerOnOff').getDatum('state')

  _getState: ->
    power = @getConnectionTarget('powerOnOff').getAspect('powerOnOff')
    dimmer = @getConnectionTarget('brightness').getAspect('brightness')
    power: power.getDatum('state')
    brightness: dimmer.getDatum('state')

  describeState: (state) ->
    if state.power == true
      if state.brightness?
        "On at #{state.brightness}% brightness"
      else
        'On'
    else if state.power == false
      'Off'
    else
      'not reporting status'