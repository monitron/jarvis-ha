
[AdapterNode] = require('../../AdapterNode')
moment = require('moment')
_ = require('underscore')

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
    windSpeedSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    windGustSpeedSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    windDirectionSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    precipitationRateSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    precipitationQuantitySensor:
      events:
        changed: (prev, cur) -> !_.isEqual(prev, cur)
    ultravioletIndexSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    stillCamera:
      events:
        changed: (prev, cur) -> prev.captureTime < cur.captureTime

  processData: (datum) ->
    skyData = datum.Data
    if skyData?
      @getAspect('temperatureSensor').setData
        value: skyData.Temperature
      @getAspect('humiditySensor').setData
        value: skyData.Humidity
      @getAspect('pressureSensor').setData
        value: skyData.Pressure
      @getAspect('dayNightSensor').setData
        value: skyData.Night
      @getAspect('liquidPresenceSensor').setData
        value: skyData.Rain
      @getAspect('stillCamera').setData
        imageLocation: skyData.ImageURL
        captureTime: moment(skyData.ImageTS, 'X').toISOString()
    stormData = datum.Storm
    if stormData?
      @getAspect('precipitationRateSensor').setData
        value: stormData.RainRate
      @getAspect('ultravioletIndexSensor').setData
        value: parseInt(stormData.UVIndex) # "1"
      @getAspect('precipitationQuantitySensor').setData
        '24hour': stormData["24hRain"]
        today:    stormData.RainDaily
      @getAspect('windSpeedSensor').setData
        value: stormData.SustainedWindSpeed
      @getAspect('windGustSpeedSensor').setData
        value: stormData.WindGust
      @getAspect('windDirectionSensor').setData
        value: @_cardinalDirectionToAngle(stormData.WindDirection)

  _cardinalDirectionToAngle: (card) ->
    {
      N:   0
      NNE: 22.5
      NE:  45
      ENE: 67.5
      E:   90
      ESE: 112.5
      SE:  135
      SSE: 157.5
      S:   180
      SSW: 202.5
      SW:  225
      WSW: 247.5
      W:   270
      WNW: 292.5
      NW:  315
      NNW: 337.5
    }[card]