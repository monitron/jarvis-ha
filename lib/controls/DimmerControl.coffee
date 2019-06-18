[Control] = require('../Control')

module.exports = class DimmerControl extends Control
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
    setBrightness:
      execute: (control, params) ->
        target = control.getConnectionTarget('brightness')
        target.getAspect('brightness').executeCommand 'set',
          parseInt(params.value)
      wouldHaveEffect: (params, state) ->
        state.brightness != parseInt(params.value)
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

  _getConsumptionRates: ->
    state = @_getState()
    rating = @get('parameters').ratedElectricalPower
    if rating? and state.power?
      electricity:
        if state.power and state.brightness?
          rating * (state.brightness / 100)
        else
          if state.power then rating else 0
    else
      null

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
