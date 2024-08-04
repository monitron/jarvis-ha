[AdapterNode] = require('../../AdapterNode')

module.exports = class ESPHomeEntityNode extends AdapterNode
  initialize: ->
    super
    @get('entity').on 'state', (state) => @processData(state)
