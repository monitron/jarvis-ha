_ = require('underscore')
Backbone = require('backbone')

class MediaZone extends Backbone.Model
  defaults:
    connections: {}

  initialize: (attrs, options) ->
    @_parent = @collection.parent
    @_server = @collection.server

    # Notice when our connections' data changes
    for source in @get('connections')
      @_server.adapters.onEventAtPath source.path,
        'aspectData:change', => @trigger 'change', this

  isValid: ->
    _.every @get('connections'), (connection) =>
      p = @_server.adapters.getPath(connection.path)
      unless p? then @log 'warn', "Connected path #{connection.path} is missing"
      p?

  summarizeBasics: ->
    basics = {}
    for aspectName in ['powerOnOff', 'mediaSource', 'volume', 'mute']
      aspect = @getSourceAspect(aspectName)
      if aspect? then basics[aspectName] = aspect.getDatum('state')
    basics

  summarizeSources: ->
    aspect = @getSourceAspect('mediaSource')
    return [] unless aspect
    for sourceId, sourceName of aspect.getAttribute('choices')
      sourceDef = _.findWhere(@get('sources'), {id: sourceId}) or {}
      # + source media metadata and transport details
      id: sourceId
      name: sourceDef.name or sourceName
      icon: sourceDef.icon

  setBasic: (aspectName, newState) ->
    @getSourceAspect(aspectName).executeCommand('set', newState)

  getSourceAspect: (aspect) ->
    path = @getSourcePath(aspect)
    return undefined unless path?
    @_server.adapters.getPath(path)?.getAspect(aspect)

  getSourcePath: (aspect) ->
    source = _.find(@get('connections'), (s) -> _.contains(s.aspects, aspect))
    return undefined unless source?
    source.path

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
