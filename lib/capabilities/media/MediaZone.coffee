_ = require('underscore')
Q = require('q')
Backbone = require('backbone')

class MediaZone extends Backbone.Model
  defaults:
    connections: []
    sources: []
    powerOnDelay: 0

  initialize: (attrs, options) ->
    @_parent = @collection.parent
    @_server = @collection.server

    # Notice when our connections' data changes
    for connection in @get('connections')
      @_server.adapters.onEventAtPath connection.path,
        'aspectData:change', => @trigger 'change', this

    if @has('source')
      @set 'single-source', true
      @set 'sources', [_.defaults(id: 'single', @get('source'))]
      @unset 'source'

    for source in @get('sources')
      for connection in source.connections or []
        @_server.adapters.onEventAtPath connection.path,
          'aspectData:change', => @trigger 'change', this

  isValid: ->
    _.every @get('connections'), (connection) =>
      p = @_server.adapters.getPath(connection.path)
      unless p? then @log 'warn', "Connected path #{connection.path} is missing"
      p?.isValid()

  summarizeBasics: ->
    basics = {}
    for aspectName in ['powerOnOff', 'mediaSource', 'volume', 'mute']
      aspect = @getConnectionAspect(aspectName)
      if aspect? then basics[aspectName] = aspect.getDatum('state')
    basics

  summarizeSources: ->
    if @get('single-source')
      sources = single: 'Single Source'
    else
      aspect = @getConnectionAspect('mediaSource')
      return [] unless aspect
      sources = aspect.getAttribute('choices')
    for sourceId, sourceName of sources
      sourceDef = _.findWhere(@get('sources'), {id: sourceId}) or {}
      id: sourceId
      name: sourceDef.name or sourceName
      icon: sourceDef.icon
      transport: @getSourceConnectionAspect(sourceId, 'mediaTransport')?.getData()
      metadata: @getSourceConnectionAspect(sourceId, 'mediaMetadata')?.getData()

  setBasic: (aspectName, newState) ->
    @getConnectionAspect(aspectName).executeCommand('set', newState)

  powerOn: ->
    deferred = Q.defer()
    powerOnOff = @getConnectionAspect('powerOnOff')
    if !powerOnOff?
      deferred.resolve
    else
      # Send power on command either way, but if we thought it was already on,
      # don't bother waiting out the delay before sending further commands
      delayTime = if powerOnOff.getDatum('state') then 0 else @get('powerOnDelay')
      @setBasic('powerOnOff', true)
        .fail (err) => deferred.reject(err)
        .then => setTimeout((=> deferred.resolve()), delayTime)
    deferred.promise

  sourceCommand: (sourceId, command) ->
    @getSourceConnectionAspect(sourceId, 'mediaTransport').
      executeCommand(command)

  getConnectionAspect: (aspect) ->
    path = @getConnectionPath(aspect)
    return undefined unless path?
    @_server.adapters.getPath(path)?.getAspect(aspect)

  getConnectionPath: (aspect) ->
    conn = _.find(@get('connections'), (s) -> _.contains(s.aspects, aspect))
    return undefined unless conn?
    conn.path

  getSourceConnectionAspect: (source, aspect) ->
    path = @getSourceConnectionPath(source, aspect)
    return undefined unless path?
    @_server.adapters.getPath(path)?.getAspect(aspect)

  getSourceConnectionPath: (source, aspect) ->
    connections = _.findWhere(@get('sources'), id: source)?.connections
    return unless connections?
    conn = _.find(connections, (s) -> _.contains(s.aspects, aspect))
    return undefined unless conn?
    conn.path

  toStateJSON: ->
    valid: @isValid()
    basics: @summarizeBasics()
    sources: @summarizeSources()

  log: (level, message) ->
    @_parent.log level, "[#{@get('id')} zone] #{message}"

class MediaZones extends Backbone.Collection
  model: MediaZone

  initialize: (models, options) ->
    @parent = options.parent
    @server = options.server

module.exports = [MediaZone, MediaZones]
