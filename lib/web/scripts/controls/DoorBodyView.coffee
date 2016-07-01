
Backbone = require('backbone')
_ = require('underscore')

module.exports = class DoorBodyView extends Backbone.View
  events:
    "click .button": "sendButtonCommand"

  statusLookup: [ # undefined means unknown; null means not present
      {locked: undefined, open: undefined, text: 'Unknown',     safe: undefined},
      {locked: undefined, open: null,      text: 'Unknown',     safe: undefined},
      {locked: undefined, open: false,     text: 'Closed/?',    safe: undefined},
      {locked: undefined, open: true,      text: 'Open/?',      safe: false},
      {locked: null,      open: undefined, text: 'Unknown',     safe: undefined}
      {locked: null,      open: null,      text: 'Unknown',     safe: undefined},
      {locked: null,      open: false,     text: 'Closed',      safe: true},
      {locked: null,      open: true,      text: 'Open',        safe: false},
      {locked: false,     open: undefined, text: 'Unlocked/?',  safe: false}
      {locked: false,     open: null,      text: 'Unlocked',    safe: false},
      {locked: false,     open: true,      text: 'Open',        safe: false},
      {locked: false,     open: false,     text: 'Unlocked',    safe: false},
      {locked: true,      open: undefined, text: 'Locked/?',    safe: undefined}
      {locked: true,      open: null,      text: 'Locked',      safe: true},
      {locked: true,      open: true,      text: 'Locked Open', safe: false},
      {locked: true,      open: false,     text: 'Locked',      safe: true}
    ]

  render: ->
    state = @model.get('state')
    statusDetails = _.findWhere(@statusLookup,
      locked: if state.hasLock then state.locked else null
      open:   if state.hasSensor then state.open else null)
    context =
      isSafe:     !!statusDetails.safe
      isUnsafe:   statusDetails.safe == false
      text:       statusDetails.text
      hasSensor:  state.hasSensor
      hasLock:    state.hasLock
      isLocked:   state.locked
      isUnlocked: !state.locked
    @$el.html Templates['controls/door'](context)
    this

  sendButtonCommand: (event) ->
    @model.sendCommand $(event.target).closest('.button').data('command')