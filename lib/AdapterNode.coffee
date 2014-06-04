_ = require('underscore')
Backbone = require('backbone')
Aspect = require('./Aspect')

class AdapterNode extends Backbone.Model
  aspects: {}

  initialize: (attributes, options) ->
    @adapter = options?.adapter or this
    @children = (new AdapterNodes)
    @_valid = true
    @_aspects = {}
    # Instantiate preconfigured aspects
    _.each @aspects, (aspectConfig, aspectId) =>
      aspect = new Aspect(this, aspectConfig)
      aspect.on 'aspectEvent', (event) =>
        @log "debug", "Aspect #{aspectId} emitted event: #{event}"
      @_aspects[aspectId] = aspect

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

  processData: ->
    @log "error", "AdapterNode subclass must override processData method"

  refreshData: ->
    @adapter.refreshData()


class AdapterNodes extends Backbone.Collection
  model: AdapterNode

module.exports = [AdapterNode, AdapterNodes]