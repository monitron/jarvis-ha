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
          operative = node.getAspect('discreteSpeed').getDatum('state') != value
          node.adapter.executeCommand node.id, 'DON',
            [node.SPEED_MAP[value]], operative
      attributes:
        choices: [
          {id: 'off',  shortName: 'Off',  longName: 'Off'}
          {id: 'low',  shortName: 'Low',  longName: 'Low'}
          {id: 'med',  shortName: 'Med',  longName: 'Medium'}
          {id: 'high', shortName: 'High', longName: 'High'}]

  processData: (data) ->
    if data.ST?
      @getAspect('discreteSpeed').setData
        state: _.findKey(@SPEED_MAP, (value) -> value.toString() == data.ST)