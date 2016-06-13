
Backbone = require('backbone')

module.exports = class DimmerControlBodyView extends Backbone.View
  events:
    "click .button": "sendButtonCommand"
    "click .slider": "sendBrightnessCommand"

  render: ->
    controlState = @model.get('state')
    context =
      isOff:      controlState.power == false # as in not undefined
      isOn:       controlState.power == true
      brightness: controlState.brightness
    @$el.html Templates['controls/dimmer'](context)
    this

  sendButtonCommand: (event) ->
    @model.sendCommand $(event.target).data('command')

  sendBrightnessCommand: (event) ->
    newBrightness = (event.offsetX / $(event.target).width()) * 100
    @model.sendCommand 'setBrightness', value: newBrightness