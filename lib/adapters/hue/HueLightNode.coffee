HueNode = require('./HueNode')

module.exports = class HueLightNode extends HueNode
  setState: (state) ->
    @adapter.setLightState @id, state

  processData: (data) ->
    @_processData data
