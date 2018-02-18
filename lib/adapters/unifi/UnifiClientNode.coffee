
[AdapterNode] = require('../../AdapterNode')

module.exports = class UnifiClientNode extends AdapterNode
  aspects:
    networkPresenceSensor: {}

  processData: (datum) ->
    @getAspect('networkPresenceSensor').setData value: datum
