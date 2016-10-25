[Control] = require('../Control')

module.exports = class FanSpeedControl extends Control
  commands:
    set: (control, params) ->
      target = control.getConnectionTarget('discreteSpeed')
      target.getAspect('discreteSpeed').executeCommand 'set', params.value

  isActive: ->
    speed = @getConnectionTarget('discreteSpeed')?.getAspect('discreteSpeed').
      getDatum('state')
    speed? and speed != 'off'

  _getState: ->
    speed = @getConnectionTarget('discreteSpeed').getAspect('discreteSpeed')
    speed: speed.getDatum('state')
    speedChoices: speed.getAttribute('choices')
