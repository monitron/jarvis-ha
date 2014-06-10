
Backbone = require('backbone')

module.exports = class ControlView extends Backbone.View
  tagName: 'li'

  render: ->
    context =
      name: @model.control.get('name')
    @$el.html Templates['control'](context)
    this
