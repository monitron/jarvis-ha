
[AdapterNode] = require('../../AdapterNode')

module.exports = class NestThermostatNode extends AdapterNode
  aspects:
    temperatureSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    humiditySensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    temperatureSetPoint:
      commands:
        setTarget: (node, temp) ->
          node.adapter.setTemperature(node.id, temp).then ->
            aspect = node.getAspect('temperatureSetPoint')
            aspect.setData {target: temp, mode: aspect.getDatum('mode')}
        setMode: (node, mode) ->
          node.adapter.setTemperature(node.id, temp).then ->
            aspect = node.getAspect('temperatureSetPoint')
            aspect.setData {target: aspect.getDatum('target'), mode: mode}
      events:
        targetChanged: (prev, cur) -> prev.target != cur.target
        modeChanged:   (prev, cur) -> prev.mode != cur.mode
      attributes:
        modeChoices:
          cool: "Cool"
          heat: "Heat"
          off:  "Off"

  processData: (data) ->
    @getAspect("temperatureSensor").setData
      value: data["currentTemperature"]
    @getAspect("humiditySensor").setData
      value: data["currentHumidity"]
    @getAspect("temperatureSetPoint").setData
      target: data["targetTemperature"]
      mode: data["targetType"]
