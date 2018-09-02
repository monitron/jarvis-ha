[AdapterNode] = require('../../AdapterNode')

module.exports = class BLEDeviceNode extends AdapterNode
  aspects:
    signalStrengthSensor: {}

  processData: (peripheral) ->
    @getAspect('signalStrengthSensor').setData value: peripheral.rssi