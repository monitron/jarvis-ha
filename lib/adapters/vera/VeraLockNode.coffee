
_ = require('underscore')
[AdapterNode] = require('../../AdapterNode')

module.exports = class VeraLockNode extends AdapterNode
  serviceId: 'urn:micasaverde-com:serviceId:DoorLock1'

  aspects:
    lock:
      commands:
        lock:   (node) -> node.adapter.requestAction(node.id, node.serviceId,
                  'SetTarget', {newTargetValue: 1}).then ->
                  node.getAspect('lock').setData state: true
        unlock: (node) -> node.adapter.requestAction(node.id, node.serviceId,
                  'SetTarget', {newTargetValue: 0}).then ->
                  node.getAspect('lock').setData state: false
    batteryLevelSensor: {}

  processData: (states) ->
    for state in states
      switch state.variable
        when 'Status'
          @getAspect('lock').setData state: state.value == '1'
        when 'BatteryLevel'
          value = Number(state.value)
          if _.isNumber(value)
            @getAspect('batteryLevelSensor').setData value: value