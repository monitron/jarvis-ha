
[AdapterNode] = require('../../AdapterNode')

module.exports = class EcobeeSensorNode extends AdapterNode
  aspects:
    temperatureSensor: {}
    humiditySensor: {}
    occupancySensor: {}

  processData: (data) ->
    for capability in data.capability
      switch capability.type
        when 'temperature'
          @getAspect('temperatureSensor').setData
            value: ((Number(capability.value) / 10.0) - 32) * (5 / 9.0)
        when 'humidity'
          @getAspect('humiditySensor').setData
            value: Number(capability.value)
        when 'occupancy'
          @getAspect('occupancySensor').setData
            value: capability.value == 'true'
