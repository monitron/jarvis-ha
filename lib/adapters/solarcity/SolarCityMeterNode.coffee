
[AdapterNode] = require('../../AdapterNode')

module.exports = class SolarCityMeterNode extends AdapterNode
  aspects:
    energySensor: {}

  processData: (datum) ->
    @getAspect('energySensor').setData value: datum # kWh