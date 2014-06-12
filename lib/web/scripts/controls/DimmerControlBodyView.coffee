
Backbone = require('backbone')

module.exports = class DimmerControlBodyView extends Backbone.View
  events:
    "click .button": "sendButtonCommand"

  render: ->
    @$el.html Templates['controls/dimmer']()
    this

  sendButtonCommand: (event) ->
    @model.sendCommand $(event.target).data('command')