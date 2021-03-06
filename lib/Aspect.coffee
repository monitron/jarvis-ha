
EventEmitter = require('events').EventEmitter
_ = require('underscore')

module.exports = class Aspect extends EventEmitter
  constructor: (@_node, config) ->
    # Pass me an object with keys: attributes, commands, events
    # All commands must return a promise
    @config = _.extend({attributes: {}, commands: {}, events: {}}, config)
    @_data = {}

  setData: (newData) ->
    for event, conditionalFn of @config.events
      if conditionalFn(@_data, newData) then @emit('aspectEvent', event)
    oldData = @_data
    @_data = newData
    unless _.isEqual(oldData, @_data) then @emit('dataChanged', @_data, oldData)

  setDatum: (key, value) ->
    # set datum individually, leaving others alone
    data = _.clone(@getData() or {})
    data[key] = value
    @setData data

  clearData: ->
    @setData {}

  getData: ->
    @_data

  getDatum: (id) ->
    @_data[id]

  getAttribute: (id) ->
    @config.attributes[id]

  setAttribute: (id, value) ->
    @config.attributes[id] = value

  executeCommand: (commandId, args...) ->
    @config.commands[commandId](@_node, args...)

  toJSON: ->
    data: @_data
