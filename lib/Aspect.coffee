
EventEmitter = require('events').EventEmitter
_ = require('underscore')

module.exports = class Aspect extends EventEmitter
  constructor: (@_node, config) ->
    # Pass me an object with keys: attributes, commands, events
    @config = _.extend({attributes: {}, commands: {}, events: {}}, config)
    @_data = {}

  setData: (newData) ->
    for event, conditionalFn of @config.events
      if conditionalFn(@_data, newData) then @emit('aspectEvent', event)
    @_data = newData

  getData: ->
    @_data

  getDatum: (id) ->
    @_data[id]

  doCommand: (commandId, args...) ->
    @config.commands[commandId](@_node, args...)
