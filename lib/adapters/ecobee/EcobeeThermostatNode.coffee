
EcobeeNode = require('./EcobeeNode')

module.exports = class EcobeeThermostatNode extends EcobeeNode
  aspects:
    temperatureSensor: {}
    humiditySensor: {}

  processData: (data) ->
    temp = data.runtime?.actualTemperature
    if temp? then @getAspect('temperatureSensor').setData
      value: @_convertTemp(temp)
    hum = data.runtime?.actualHumidity
    if hum? then @getAspect('humiditySensor').setData
      value: Number(hum)
