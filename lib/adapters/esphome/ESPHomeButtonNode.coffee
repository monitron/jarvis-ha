Q = require('q')
ESPHomeEntityNode = require('./ESPHomeEntityNode')

module.exports = class ESPHomeButtonNode extends ESPHomeEntityNode
  entityType: 'Button'

  aspects:
    oneShotActuator:
      commands:
        actuate: (node) ->
          node.get('entity').push()
          Q.fcall(-> true)

  processData: ->