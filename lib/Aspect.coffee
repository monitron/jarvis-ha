
EventEmitter = require('events').EventEmitter

module.exports = class Aspect extends EventEmitter
  constructor: (@_node, @config) ->
    # Pass me an object with keys: attributes, commands, events
    @_data = {}

  setData: (@_data) ->
    # TODO Fire events based on difference

  getData: ->
    @_data

  getDatum: (id) ->
    @_data[id]

  doCommand: (commandId, args...) ->
    @config.commands[commandId](@_node, args...)
