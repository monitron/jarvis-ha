[Control] = require('../Control')

module.exports = class DoorControl extends Control
  commands:
    unlock: (control, params) ->
      target = control.getConnectionTarget('lock')
      target.getAspect('lock').executeCommand 'unlock'
    lock: (control, params) ->
      target = control.getConnectionTarget('lock')
      target.getAspect('lock').executeCommand 'lock'

  _isActive: ->
    sensor = @getConnectionTarget('openCloseSensor')
    lock = @getConnectionTarget('lock')
    unsafe = false
    if sensor?.hasAspect('openCloseSensor')
      state = sensor.getAspect('openCloseSensor').getDatum('state')
      unsafe = state != false
    if !unsafe and lock?.hasAspect('lock')
      state = lock.getAspect('lock').getDatum('state')
      unsafe = state != true
    unsafe

  _getState: ->
    sensor = @getConnectionTarget('openCloseSensor')
    lock = @getConnectionTarget('lock')
    hasSensor: sensor?.hasAspect('openCloseSensor')
    hasLock: lock?.hasAspect('lock')
    open: sensor?.getAspect('openCloseSensor').getDatum('state')
    locked: lock?.getAspect('lock').getDatum('state')
