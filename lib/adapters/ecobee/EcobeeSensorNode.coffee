
EcobeeNode = require('./EcobeeNode')

module.exports = class EcobeeSensorNode extends EcobeeNode
  aspects:
    temperatureSensor: {}
    humiditySensor: {}
    occupancySensor: {}

  processData: (data) ->
    for capability in data.capability
      switch capability.type
        when 'temperature'
          @getAspect('temperatureSensor').setData
            value: @_convertTemp(capability.value)
        when 'humidity'
          @getAspect('humiditySensor').setData
            value: Number(capability.value)
        when 'occupancy'
          @getAspect('occupancySensor').setData
            value: capability.value == 'true'
