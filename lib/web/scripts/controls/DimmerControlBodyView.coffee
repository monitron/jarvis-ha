
Backbone = require('backbone')

module.exports = class DimmerControlBodyView extends Backbone.View
  render: ->
    @$el.html Templates['controls/dimmer']()
    this