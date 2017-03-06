IsyNode = require('./IsyNode')

module.exports = class IsyInsteonOpenCloseSensorNode extends IsyNode
  key: 'insteonOpenCloseSensor'
  types: [[16, 2]]

  aspects:
    openCloseSensor: {}

  processData: (data) ->
    if data.ST?
      value = data.ST != '0'
      if @configuration('invert') and value? then value = !value
      @getAspect('openCloseSensor').setData state: value
