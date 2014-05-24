_ = require('underscore')
Aspect = require('./Aspect')

module.exports = class Node
  aspects: {}

  constructor: (@id, @adapter, @config) ->
    @_nodes = []
    @_valid = true
    @config ||= {}
    @_aspects = {}
    # Instantiate preconfigured aspects
    for aspectId, aspectConfig of @aspects
      @_aspects[aspectId] = new Aspect(this, aspectConfig)

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

  getAspect: (id) ->
    @_aspects[id]

  getAspectIds: ->
    _.keys(@_aspects)