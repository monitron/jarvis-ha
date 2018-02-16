_ = require('underscore')

[AdapterNode] = require('../../AdapterNode')

module.exports = class MockNode extends AdapterNode
  aspects: ->
    _.mapObject(@get('aspects'), {})

  initialize: ->
    super
    # Set initial data
    for aspectId, config of @get('aspects') when config.data?
      @getAspect(aspectId).setData config.data
