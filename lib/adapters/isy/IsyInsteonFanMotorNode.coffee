_ = require('underscore')
IsyNode = require('./IsyNode')

module.exports = class IsyInsteonFanMotorNode extends IsyNode
  key: 'insteonFanMotor'

  SPEED_MAP:
    off: 0
    low: 63
    med: 191
    high: 255

  aspects:
    discreteSpeed:
      commands:
        set: (node, value) ->
          node.adapter.executeCommand node.id, 'DON', node.SPEED_MAP[value]
      attributes:
        choices: [
          {id: 'off',  name: 'Off'}
          {id: 'low',  name: 'Low'}
          {id: 'med',  name: 'Med'}
          {id: 'high', name: 'High'}]

  processData: (data) ->
    if data.ST?
      @getAspect('discreteSpeed').setData
        state: _.findKey(@SPEED_MAP, (value) -> value.toString() == data.ST)