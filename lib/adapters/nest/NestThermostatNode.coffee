
NestNode = require('./NestNode')

module.exports = class NestThermostatNode extends NestNode
  aspects:
    "temperature-sensor": {}
    "humidity-sensor": {}
    "temperature-set-point":
      commands:
        "set-target": (node, temp) -> node.adapter.setTemperature(node.id, temp)
      events:
        "target-changed": (prev, cur) -> prev.target != cur.target
        "mode-changed"  : (prev, cur) -> prev.mode != cur.mode

  processData: (data) ->
    @getAspect("temperature-sensor").setData
      value: data["current-temperature"]
    @getAspect("humidity-sensor").setData
      value: data["current-humidity"]
    @getAspect("temperature-set-point").setData
      target: data["target-temperature"]
      mode: data["target-type"]
