[Control] = require('../Control')

module.exports = class MediaControl extends Control
  commands:
    turnOff: (control, params)->
      target = control.getConnectionTarget('powerOnOff')
      target.getAspect('powerOnOff').executeCommand 'set', false
    turnOn: (control, params) ->
      target = control.getConnectionTarget('powerOnOff')
      target.getAspect('powerOnOff').executeCommand 'set', true
    setSource: (control, params) ->
      target = control.getConnectionTarget('mediaSource')
      target.getAspect('mediaSource').executeCommand 'set', params.value

  _getState: ->
    power = @getConnectionTarget('powerOnOff').getAspect('powerOnOff')
    source = @getConnectionTarget('mediaSource').getAspect('mediaSource')
    power: power.getDatum('state')
    source: source.getDatum('state')
    sourceChoices: source.getAttribute('choices')
