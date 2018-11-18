_ = require('underscore')
[Control] = require('../Control')

module.exports = class DoorControl extends Control
  commands:
    unlock:
      execute: (control, params) ->
        target = control.getConnectionTarget('lock')
        target.getAspect('lock').executeCommand 'unlock'
      wouldHaveEffect: (params, state) -> state.locked != false
    lock:
      execute: (control, params) ->
        target = control.getConnectionTarget('lock')
        target.getAspect('lock').executeCommand 'lock'
      wouldHaveEffect: (params, state) -> state.locked != true

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

  describeStateTransition: (before, after) ->
    changes = []
    if before.open? and after.open? and before.open != after.open
      changes.push if after.open then 'opened' else 'closed'
    if before.locked? and after.locked? and before.locked != after.locked
      changes.push if after.locked then 'locked' else 'unlocked'
    return null if _.isEmpty(changes)
    "was #{changes.join(' and ')}"