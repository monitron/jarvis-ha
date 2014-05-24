_ = require('underscore')

module.exports = class Node
  constructor: (@id, @adapter, @config) ->
    @_nodes = []
    @_valid = true
    @config ||= {}

  addChild: (node) ->
    @_nodes.push node

  getChild: (id) ->
    _.findWhere(@_nodes, id: id)

  getChildIds: ->
    _.pluck(@_nodes, "id")

  isValid: ->
    @_valid

  setValid: (@_valid) ->
    @log "debug", "Became #{if @_valid then 'valid' else 'invalid'}"

  log: (level, message) ->
    @adapter.log level, "[Node #{@id}] #{message}"
