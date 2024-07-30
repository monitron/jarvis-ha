ESPHomeEntityNode = require('./ESPHomeEntityNode')

module.exports = class ESPHomeCoverNode extends ESPHomeEntityNode
  entityType: 'Cover'

  aspects:
    openCloseSensor: {}

  processData: (data) ->
    @getAspect('openCloseSensor').setData state: !!data.position
