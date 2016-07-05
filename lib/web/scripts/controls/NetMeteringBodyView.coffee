
Backbone = require('backbone')
_ = require('underscore')

module.exports = class NetMeteringBodyView extends Backbone.View
  render: ->
    state = @model.get('state')
    max = _.max(
