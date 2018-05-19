_ = require('underscore')
[Control] = require('../Control')

module.exports = class FanSpeedControl extends Control
  commands:
    setDiscreteSpeed: (control, params) ->
      target = control.getConnectionTarget('discreteSpeed')
      target.getAspect('discreteSpeed').executeCommand 'set', params.value
    turnOff: (control, params) ->
      target = control.getConnectionTarget('discreteSpeed')
      target.getAspect('discreteSpeed').executeCommand 'set', 'off'

  isActive: ->
    speed = @getConnectionTarget('discreteSpeed')?.getAspect('discreteSpeed').
      getDatum('state')
    speed? and speed != 'off'

  _getState: ->
    speed = @getConnectionTarget('discreteSpeed').getAspect('discreteSpeed')
    speed: speed.getDatum('state')
    speedChoices: speed.getAttribute('choices')
    speedName: _.findWhere(speed.getAttribute('choices'),
      id: speed.getDatum('state'))?.longName

  resolveSpeedName: (name) ->
    name = name.toLowerCase()
    speed = @getConnectionTarget('discreteSpeed').getAspect('discreteSpeed')
    choices = speed?.getAttribute('choices') or []
    matching = _.find choices, (choice) ->
      choice.shortName.toLowerCase() == name or
        choice.longName.toLowerCase() == name
    matching?.id

  describeState: (state) ->
    if state.speedName?
      "Set to #{state.speedName}"
    else
      'not reporting status'

  describeStateTransition: (before, after) ->
    return null unless before.speed?
    if after.speed == 'off'
      'was turned off'
    else if before.speed == 'off'
      "was turned on at #{after.speedName}"
    else
      "was changed to #{after.speedName}"
