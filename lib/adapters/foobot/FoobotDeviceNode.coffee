
_ = require('underscore')

[AdapterNode] = require('../../AdapterNode')

module.exports = class FoobotDeviceNode extends AdapterNode
  aspects:
    temperatureSensor: {}
    humiditySensor: {}
    particulateMatterSensor: {}
    volatileOrganicCompoundSensor: {}

  processData: (data) ->
    @getAspect('temperatureSensor').setData             value: data.tmp # C
    @getAspect('humiditySensor').setData                value: data.hum # 0-100%
    @getAspect('particulateMatterSensor').setData       value: data.pm  # ug/m3
    @getAspect('volatileOrganicCompoundSensor').setData value: data.voc # ppb

  fetch: ->
    params = sensorList: 'pm,voc,hum,tmp'
    @adapter.request("device/#{@id}/datapoint/0/last/0/", params)
      .then (data) =>
        @processData _.object(data.sensors, data.datapoints[0])
      .fail (err) =>
        @log 'warn', "Failed to get data for #{@id} (#{err})"
      .done()
