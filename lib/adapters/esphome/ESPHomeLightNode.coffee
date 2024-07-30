Q = require('q')
ESPHomeEntityNode = require('./ESPHomeEntityNode')

module.exports = class ESPHomeLightNode extends ESPHomeEntityNode
  entityType: 'Light'

  aspects:
    powerOnOff:
      commands:
        set: (node, value) ->
          node.get('entity').setState(value)
          Q.fcall(-> true)

  processData: (data) ->
    @getAspect('powerOnOff').setData state: data.state