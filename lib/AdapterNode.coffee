_ = require('underscore')
Backbone = require('backbone')
Aspect = require('./Aspect')

class AdapterNode extends Backbone.Model
  deepEvents: ['aspectData:change']

  aspects: {}

  # Takes options:
  #   adapter    - (required) a reference to the parent adapter
  #   attributes - A map of aspect names to maps of attributes to set on them
  initialize: (attributes, options) ->
    @adapter = options?.adapter or this
    @server = options?.server
    @children = new AdapterNodes()
    @_valid = true
    # Generate deepEvents as needed
    _.each @deepEvents, (ev) =>
      @listenTo this, ev, (args...) => @trigger 'deepEvent', [@id], ev, args
    # Forward deepEvent messages from children
    @listenTo @children, 'deepEvent', (path, args...) =>
      @trigger 'deepEvent', [@id].concat(path), args...
    # Instantiate preconfigured aspects
    @_aspects = {}
    _.each @aspects, (aspectConfig, aspectId) =>
      # Copy in aspect attributes as passed in options
      aspectConfig.attributes = _.clone(aspectConfig.attributes) or {}
      _.extend(aspectConfig.attributes, options.attributes?[aspectId] or {})
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

  hasAspect: (id) ->
    @getAspect(id)?

  getAspectIds: ->
    _.keys(@_aspects)

  processData: ->
    @log "error", "AdapterNode subclass must override processData method"

  refreshData: ->
    @adapter.refreshData()


class AdapterNodes extends Backbone.Collection
  model: AdapterNode

  getPath: (path) ->
    path = _.clone(path)
    node = @get(path.shift())
    if _.isEmpty(path) then node else node?.children.getPath(path)

  onEventAtPath: (path, event, callback) ->
    @listenTo this, 'deepEvent', (evPath, evEvent, args) ->
      if _.isEqual(evPath, path) and event == evEvent then callback(args)


module.exports = [AdapterNode, AdapterNodes]