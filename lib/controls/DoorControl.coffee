[Control] = require('../Control')

module.exports = class DoorControl extends Control
  commands:
    unlock: (control, params) ->
      target = control.getConnectionTarget('lock')
      target.getAspect('lock').executeCommand 'unlock'
    lock: (control, params) ->
      target = control.getConnectionTarget('lock')
      target.getAspect('lock').executeCommand 'lock'

  _getState: ->
    sensor = @getConnectionTarget('openCloseSensor')
    lock = @getConnectionTarget('lock')
    hasSensor: sensor?.hasAspect('openCloseSensor')
    hasLock: lock?.hasAspect('lock')
    open: sensor?.getAspect('openCloseSensor').getDatum('state')
    locked: lock?.getAspect('lock').getDatum('state')
