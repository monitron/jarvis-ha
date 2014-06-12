_ = require('underscore')
Backbone = require('backbone')
Aspect = require('./Aspect')

class AdapterNode extends Backbone.Model
  deepEvents: ['aspectData:change']

  aspects: {}

  initialize: (attributes, options) ->
    @adapter = options?.adapter or this
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

  getPath: (path) ->
    path = _.clone(path)
    node = @get(path.shift())
    if _.isEmpty(path) then node else node.children.getPath(path)

  onEventAtPath: (path, event, callback) ->
    @listenTo this, 'deepEvent', (evPath, evEvent, args) ->
      if _.isEqual(evPath, path) and event == evEvent then callback(args)


module.exports = [AdapterNode, AdapterNodes]