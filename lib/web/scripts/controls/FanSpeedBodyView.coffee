
Backbone = require('backbone')

module.exports = class FanSpeedBodyView extends Backbone.View
  events:
    "click .button": "sendButtonCommand"

  render: ->
    controlState = @model.get('state')
    # This makes the silly assumption that there are always four fan speeds
    context =
      isOff:  controlState.speed == 'off'
      isLow:  controlState.speed == 'low'
      isMed:  controlState.speed == 'med'
      isHigh: controlState.speed == 'high'
    @$el.html Templates['controls/fanSpeed'](context)
    this

  sendButtonCommand: (event) ->
    @model.sendCommand 'set', value: $(event.target).data('speed')