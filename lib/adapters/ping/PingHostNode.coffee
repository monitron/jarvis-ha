
[AdapterNode] = require('../../AdapterNode')

module.exports = class PingHostNode extends AdapterNode
  aspects:
    networkPresenceSensor: {}

  processData: (datum) ->
    @getAspect('networkPresenceSensor').setData
      value: datum