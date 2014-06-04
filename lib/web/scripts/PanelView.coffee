
Backbone = require('backbone')

module.exports = class PanelView extends Backbone.View
  render: ->
    @$el.html Templates['panel']()