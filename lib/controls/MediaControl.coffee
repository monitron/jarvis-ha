[Control] = require('../Control')

module.exports = class MediaControl extends Control
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
    setSource:
      execute: (control, params) ->
        powerTarget = control.getConnectionTarget('powerOnOff')
        sourceTarget = control.getConnectionTarget('mediaSource')
        if powerTarget?
          # Repetitive...but I can deal with this until I have "await"
          powerTarget.getAspect('powerOnOff').executeCommand('set', true).then =>
            sourceTarget.getAspect('mediaSource').executeCommand 'set', params.value
        else
          sourceTarget.getAspect('mediaSource').executeCommand 'set', params.value
      wouldHaveEffect: (params, state) -> state.source != params.value

  _isActive: ->
    @getConnectionTarget('powerOnOff').getAspect('powerOnOff').getDatum('state')

  _getState: ->
    power = @getConnectionTarget('powerOnOff').getAspect('powerOnOff')
    source = @getConnectionTarget('mediaSource').getAspect('mediaSource')
    power: power.getDatum('state')
    source: source.getDatum('state')
    sourceName: source.getAttribute('choices')[source.getDatum('state')]
    sourceChoices: source.getAttribute('choices')

  describeState: (state) ->
    if state.power == true
      if state.sourceName?
        "On with source #{state.sourceName}"
      else
        'On'
    else if state.power == false
      'Off'
    else
      'not reporting status'

  describeStateTransition: (before, after) ->
    if after.power == true
      if before.power == true and before.sourceName != after.sourceName
        "was switched to source #{after.sourceName}"
      else if before.power == false
        if after.sourceName?
          "was turned on with source #{after.sourceName}"
        else
          "was turned on"
      else
        null
    else if after.power == false
      if before.power == true
        'was turned off'
      else
        null
    else
      null