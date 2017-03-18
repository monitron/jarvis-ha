IsyNode = require('./IsyNode')

module.exports = class IsyInsteonOpenCloseSensorNode extends IsyNode
  key: 'insteonOpenCloseSensor'
  types: [[16, 2], [16, 17]]

  aspects:
    openCloseSensor: {}

  processData: (data) ->
    if data.ST?
      value = if data.ST == ' '
        undefined
      else if data.ST == '0'
        false
      else
        true
      if @configuration('invert') and value? then value = !value
      @getAspect('openCloseSensor').setData state: value
