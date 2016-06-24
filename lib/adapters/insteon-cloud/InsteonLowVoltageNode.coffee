InsteonNode = require('./InsteonNode')

# This is the basic IOLinc class; you probably want to specify a more spacific
# one to get it working with your Controls.

# IOLinc sensor must be in the default "On when closed" mode to work correctly.
# Otherwise the push status code is inverted (but not the pull code), causing
# general havoc.

module.exports = class InsteonLowVoltageNode extends InsteonNode
  interfaceType: 'iolinc'

  aspects:
    powerOnOff: # This opens and/or closes the relay depending on device config
      commands:
        set: (node, value) ->
          node.adapter.toggleLight(node.id, value).then ->
            node.getAspect('powerOnOff').setData state: value
    booleanSensor: {}

  processData: (data) ->
    if data.sensor?
      @getAspect('booleanSensor').setData state: data.sensor