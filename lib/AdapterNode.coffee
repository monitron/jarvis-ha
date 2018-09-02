_ = require('underscore')
Backbone = require('backbone')
Aspect = require('./Aspect')
Q = require('q')

class AdapterNode extends Backbone.Model
  deepEvents: ['aspectData:change', 'valid:change']

  aspects: {}

  resources: {}

  # Takes options:
  #   adapter    - (required) a reference to the parent adapter
  #   attributes - A map of aspect names to maps of attributes to set on them
  initialize: (attributes, options) ->
    @adapter = options?.adapter or this
    @server = options?.server or @adapter.server
    @children = new AdapterNodes()
    @_valid = true
    @_aspectAttributes = options.attributes or {}

    # Our logical validity changes when our adapter's changes
    if options?.adapter?
      @listenTo @adapter, 'valid:change', => @trigger 'valid:change', @isValid()
    # Generate deepEvents as needed
    _.each @deepEvents, (ev) =>
      @listenTo this, ev, (args...) => @trigger 'deepEvent', [@id], ev, args
    # Forward deepEvent messages from children
    @listenTo @children, 'deepEvent', (path, args...) =>
      @trigger 'deepEvent', [@id].concat(path), args...
    # Instantiate preconfigured aspects
    @_aspects = {}
    _.each _.result(this, 'aspects'), (aspectConfig, aspectId) =>
      @addAspect(aspectId, aspectConfig)

  isValid: ->
    @_valid and (this == @adapter or @adapter.isValid())

  setValid: (valid) ->
    if valid != @_valid
      @_valid = valid
      @log "debug", "Became #{if @_valid then 'valid' else 'invalid'}"
      @trigger 'valid:change', @_valid

  log: (level, message) ->
    @adapter.log level, "[Node #{@id}] #{message}"

  # It should be pretty unusual to create aspects on-the-fly
  addAspect: (id, config) ->
    # Copy in aspect attributes as passed in options
    config.attributes = _.extend({},
      config.attributes or {}, @_aspectAttributes[id] or {})
    aspect = new Aspect(this, config)
    aspect.on 'aspectEvent', (event) =>
      @log "debug", "Aspect #{id} emitted event: #{event}"
    aspect.on 'dataChanged', (data, oldData) =>
      @log "debug", "Aspect #{id} data became: #{JSON.stringify(data)}"
      @trigger 'aspectData:change', id, data, oldData
    @_aspects[id] = aspect

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

  getResource: (resourceId) ->
    resource = @resources[resourceId]
    if !resource?
      deferred = Q.defer()
      deferred.reject("Invalid resource id #{resourceId}")
      deferred.promise
    else
      resource(this) # This must return a promise as well

  toJSON: ->
    id: @id
    enabled: @get('enabled')
    valid: @isValid()
    children: @children
    aspects: @_aspects

class AdapterNodes extends Backbone.Collection
  model: AdapterNode

  getPath: (path) ->
    path = _.clone(path)
    node = @get(path.shift())
    if _.isEmpty(path) then node else node?.children.getPath(path)

  onEventAtPath: (path, event, callback) ->
    @listenTo this, 'deepEvent', (evPath, evEvent, args) ->
      if _.isEqual(evPath, path) and event == evEvent then callback(args...)


module.exports = [AdapterNode, AdapterNodes]