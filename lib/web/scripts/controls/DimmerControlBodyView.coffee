
Backbone = require('backbone')

module.exports = class DimmerControlBodyView extends Backbone.View
  events:
    "click .button": "handleButtonPress"

  render: ->
    @$el.html Templates['controls/dimmer']()
    this

  handleButtonPress: (event) ->
    command = $(event.target).data('command')
    window.app.sendCommand @model.id, command