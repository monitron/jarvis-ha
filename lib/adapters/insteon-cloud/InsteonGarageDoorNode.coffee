InsteonNode = require('./InsteonNode')

# This class represents an IOLinc as configured in the Insteon Garage Door Kit.

# IOLinc sensor must be in the default "On when closed" mode to work correctly.
# Otherwise the push status code is inverted (but not the pull code), causing
# general havoc.

module.exports = class InsteonGarageDoorNode extends InsteonNode
  interfaceType: 'iolinc'

  aspects:
    toggleDoorActuator:
      commands:
        toggle: (node) -> node.adapter.toggleLight(node.id, true)
    openCloseSensor: {}

  processData: (data) ->
    if data.sensor?
      @getAspect('openCloseSensor').setData state: !data.sensor