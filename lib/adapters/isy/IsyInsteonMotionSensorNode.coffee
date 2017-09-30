
IsyNode = require('./IsyNode')

module.exports = class IsyMotionSensorNode extends IsyNode
  key: 'insteonMotionSensor'
  statusQueryable: false

  aspects:
    occupancySensor: {}

  processData: (data) ->
    @getAspect('occupancySensor').setData value: data.ST == '255'