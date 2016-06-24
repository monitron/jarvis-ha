
Backbone = require('backbone')
_ = require('underscore')

module.exports = class DoorBodyView extends Backbone.View
  render: ->
    controlState = @model.get('state')
    context =
      isKnown:  controlState.open?
      isOpen:   controlState.open
      isClosed: controlState.open == false # excludes undefined
    @$el.html Templates['controls/door'](context)
    this