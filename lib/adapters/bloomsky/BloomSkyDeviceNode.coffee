
[AdapterNode] = require('../../AdapterNode')
moment = require('moment')

module.exports = class BloomSkyDeviceNode extends AdapterNode
  aspects:
    temperatureSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    humiditySensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    pressureSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    dayNightSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    liquidPresenceSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    stillCamera:
      events:
        changed: (prev, cur) -> prev.captureTime < cur.captureTime

  processData: (datum) ->
    @getAspect('temperatureSensor').setData
      value: datum.Temperature
    @getAspect('humiditySensor').setData
      value: datum.Humidity
    @getAspect('pressureSensor').setData
      value: datum.Pressure
    @getAspect('dayNightSensor').setData
      value: datum.Night
    @getAspect('liquidPresenceSensor').setData
      value: datum.Rain
    @getAspect('stillCamera').setData
      imageLocation: datum.ImageURL
      captureTime: moment(datum.ImageTS, 'X').toISOString()