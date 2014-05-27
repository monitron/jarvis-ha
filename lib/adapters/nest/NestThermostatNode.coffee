
NestNode = require('./NestNode')

module.exports = class NestThermostatNode extends NestNode
  aspects:
    temperatureSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    humiditySensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    temperatureSetPoint:
      commands:
        setTarget: (node, temp) -> node.adapter.setTemperature(node.id, temp)
      events:
        targetChanged: (prev, cur) -> prev.target != cur.target
        modeChanged  : (prev, cur) -> prev.mode != cur.mode

  processData: (data) ->
    @getAspect("temperatureSensor").setData
      value: data["currentTemperature"]
    @getAspect("humiditySensor").setData
      value: data["currentHumidity"]
    @getAspect("temperatureSetPoint").setData
      target: data["targetTemperature"]
      mode: data["targetType"]
