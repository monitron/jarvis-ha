Q = require('q')
_ = require('underscore')

[Control] = require('../Control')

module.exports = class ColorLightControl extends Control
  defaultParameters:
    powerOnToChangeColor: false

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
        control.powerOnIfNeeded().then () =>
          target = control.getConnectionTarget('brightness')
          target.getAspect('brightness').executeCommand 'set',
            parseInt(params.value)
      wouldHaveEffect: (params, state) ->
        state.brightness != parseInt(params.value)
    setChroma:
      execute: (control, params) ->
        control.powerOnIfNeeded().then () =>
          target = control.getConnectionTarget('chroma')
          target.getAspect('chroma').executeCommand 'set',
            parseChroma(params)
      wouldHaveEffect: (params, state) ->
        !_.isEqual(state.chroma, parseChroma(params))
    togglePower: (control, params) ->
      # Turns off if on. Turns on if off or undefined
      aspect = control.getConnectionTarget('powerOnOff').getAspect('powerOnOff')
      aspect.executeCommand 'set', !aspect.getDatum('state')

  powerOnIfNeeded: ->
    if @getParameter('powerOnToChangeColor') and !@getState().power
      target = @getConnectionTarget('powerOnOff')
      target.getAspect('powerOnOff').executeCommand 'set', true
    else
      Q.fcall(-> true)

  _isActive: ->
    @getConnectionTarget('powerOnOff').getAspect('powerOnOff').getDatum('state')

  _getState: ->
    power = @getConnectionTarget('powerOnOff').getAspect('powerOnOff')
    bright = @getConnectionTarget('brightness').getAspect('brightness')
    chroma = @getConnectionTarget('chroma').getAspect('chroma')
    power: power.getDatum('state')
    brightness: bright.getDatum('state')
    chroma: chroma.getData()

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
          else if after.brightness > before.brightness
            "was brightened to #{Math.round(after.brightness)}%"
          else
            'was recolored'
        else
          "was turned on at #{Math.round(after.brightness)}% brightness"
      else
        'was turned on'
    else if after.power == false
      'was turned off'
    else
      null

parseChroma = (params) ->
  chroma = {type: params.type}
  switch params.type
    when 'temperature'
      chroma.temperature = parseFloat(params.temperature)
    when 'hue-saturation'
      chroma.hue = parseFloat(params.hue)
      chroma.saturation = parseFloat(params.saturation)
    else
      @log 'warn', "Unknown chroma param type #{params.type}"
  chroma
