
[AdapterNode] = require('../../AdapterNode')
moment = require('moment')
_ = require('underscore')

module.exports = class BloomSkyDeviceNode extends AdapterNode
  invalidDatumMarker: 9999

  aspects:
    temperatureSensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    humiditySensor:
      events:
        changed: (prev, cur) -> prev.value != cur.value
    barometricPressureSensor:
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
    simpleSetData = (aspect, value, massage) =>
      aspect = @getAspect(aspect)
      if value == @invalidDatumMarker
        aspect.clearData()
      else
        if massage? then value = massage(value)
        aspect.setData value: value
    skyData = datum.Data
    if skyData?
      simpleSetData 'temperatureSensor', skyData.Temperature
      simpleSetData 'humiditySensor', skyData.Humidity
      simpleSetData 'barometricPressureSensor', skyData.Pressure
      simpleSetData 'dayNightSensor', skyData.Night
      simpleSetData 'liquidPresenceSensor', skyData.Rain
      @getAspect('stillCamera').setData
        imageLocation: skyData.ImageURL
        captureTime: moment(skyData.ImageTS, 'X').toISOString()
    stormData = datum.Storm
    if stormData?
      simpleSetData 'precipitationRateSensor', stormData.RainRate
      simpleSetData 'ultravioletIndexSensor', parseInt(stormData.UVIndex) # "1"
      simpleSetData 'windSpeedSensor', stormData.SustainedWindSpeed
      simpleSetData 'windGustSpeedSensor', stormData.WindGust
      simpleSetData 'windDirectionSensor', stormData.WindDirection,
        (dir) => @_cardinalDirectionToAngle(dir)
      @getAspect('precipitationQuantitySensor').setData
        '24hour': stormData["24hRain"]
        today:    stormData.RainDaily

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