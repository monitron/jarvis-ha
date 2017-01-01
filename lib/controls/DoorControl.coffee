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

  describeState: (state) ->
    descriptions = []
    if state.hasSensor?
      if state.open == true
        descriptions.push 'Open'
      else if state.open == false
        descriptions.push 'Closed'
      else
        descriptions.push 'not reporting open status'
    if state.hasLock?
      if state.locked == true
        descriptions.push 'Locked'
      else if state.locked == false
        descriptions.push 'Unlocked'
      else
        descriptions.push 'not reporting lock status'
    descriptions.join(' and ')