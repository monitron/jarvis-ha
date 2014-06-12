
Backbone = require('backbone')

module.exports = class DimmerControlBodyView extends Backbone.View
  events:
    "click .button": "sendButtonCommand"

  render: ->
    controlState = @model.get('state')
    context =
      isOff: controlState.power == false # as in not undefined
      isOn:  controlState.power == true
    @$el.html Templates['controls/dimmer'](context)
    this

  sendButtonCommand: (event) ->
    @model.sendCommand $(event.target).data('command')