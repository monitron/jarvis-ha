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
    togglePower: (control, params) ->
      # Turns off if on. Turns on if off or undefined
      aspect = control.getConnectionTarget('powerOnOff').getAspect('powerOnOff')
      aspect.executeCommand 'set', !aspect.getDatum('state')

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
        "On at #{Math.round(state.brightness)}% brightness"
      else
        'On'
    else if state.power == false
      'Off'
    else
      'not reporting status'

  describeStateTransition: (before, after) ->
    return null unless before.power?
    if after.power == true
      if after.brightness?
        if before.power == true and before.brightness?
          if after.brightness < before.brightness
            "was dimmed to #{Math.round(after.brightness)}%"
          else
            "was brightened to #{Math.round(after.brightness)}%"
        else
          "was turned on at #{Math.round(after.brightness)}% brightness"
      else
        'was turned on'
    else if after.power == false
      'was turned off'
    else
      null
