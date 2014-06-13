
[AdapterNode] = require('../../AdapterNode')

module.exports = class USNWSStationNode extends AdapterNode
  aspects:
    temperatureSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    humiditySensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value

  processData: (data) ->
    @getAspect("temperatureSensor").setData value: data["temperature"]
    @getAspect("humiditySensor").setData    value: data["humidity"]
