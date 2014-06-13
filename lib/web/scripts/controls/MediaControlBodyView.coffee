
Backbone = require('backbone')

module.exports = class MediaControlBodyView extends Backbone.View
  events:
    "click .button":          "sendButtonCommand"
    "click .dropdown-menu a": "sendSourceCommand"

  render: ->
    controlState = @model.get('state')
    context =
      isOff:   controlState.power == false # as in not undefined
      isOn:    controlState.power == true
      source:  controlState.sourceChoices[controlState.source]
      choices: controlState.sourceChoices
    @$el.html Templates['controls/media'](context)
    this

  sendButtonCommand: (event) ->
    @model.sendCommand $(event.target).data('command')

  sendSourceCommand: (event) ->
    @model.sendCommand 'setSource', value: $(event.target).attr('data-source')