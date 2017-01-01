
_ = require('underscore')
Backbone = require('backbone')

class Control extends Backbone.Model
  defaults: # name and type are required
    context: 'main'
    parameters: {}
    connections: {}
    memberships: []
    alternateNames: []

  defaultParameters: {}

  # All commands must return a promise
  commands: {}

  initialize: (attributes, options) ->
    @_server = options.server
    @set 'parameters', _.defaults(@get('parameters'), @defaultParameters)
    @_memberships = for membership in attributes.memberships
      _.extend(membership, path: membership.path)
    if @_server?
      # Notice when our connections' data changes
      for path in @getUniqueConnectionPaths()
        @_server.adapters.onEventAtPath path, 'aspectData:change', =>
          @trigger 'change', this

  isValid: ->
    _.every @getUniqueConnectionPaths(), (path) =>
      p = @_server.adapters.getPath(path)
      unless p? then @log 'warn', "Path #{path} is missing"
      p?

  getConnectionTarget: (connId) ->
    path = @get('connections')[connId]
    return undefined unless path?
    @_server.adapters.getPath(path)

  getUniqueConnectionPaths: ->
    uniquePaths = []
    for path in _.values(@get('connections'))
      uniquePaths.push(path) unless _.find(uniquePaths, (p) -> _.isEqual(p, path))
    uniquePaths

  getMembership: (path) ->
    _.find(@get('memberships'), (membership) -> _.isEqual(membership.path, path))

  executeCommand: (verb, params) ->
    @log 'debug', "Executing command #{verb} with params: #{JSON.stringify(params)}"
    @commands[verb](this, params)

  hasCommand: (verb) ->
    @commands[verb]?

  getState: ->
    if @isValid() then @_getState() else null

  describeCurrentState: ->
    if @isValid()
      @describeState(@_getState())
    else
      "not available"

  matchableNames: ->
    names = @get('alternateNames').concat(@get('name'))
    name.toLowerCase() for name in names

  _getState: ->
    {} # This is boring and you should probably override it

  # Override me with a function that generates English from a state object.
  # The return value should be a phrase that can follow the words "is" or "was"
  describeState: (state) ->
    "indescribable"

  isActive: ->
    if @isValid() then @_isActive() else null

  _isActive: ->
    false # Override this. In the UI, controls get highlighted when they
          # are "on" or "triggered" (a sensor) or "unlocked" (a lock) or
          # otherwise in a state where they should be noticed

  log: (level, message) ->
    # Logs through the server because including winston breaks browserify
    @_server.log level, "[#{@get('name')} control] #{message}"

  toJSON: ->
    valid = @isValid()
    _.extend super,
      commands: _.keys(@commands)
      valid: valid
      state: @getState()
      active: @isActive()


class Controls extends Backbone.Collection
  model: Control

  findMembersOfPath: (path) ->
    pairs = @map (control) ->
      control: control
      membership: control.getMembership(path)
    _.select(pairs, (p) -> p.membership?)

  findSubpathsOfPath: (path) ->
    tree = @getPathTree()
    for element in path
      tree = tree[element]
    _.keys(tree)

  getPathTree: ->
    paths = _.pluck(_.flatten(@pluck('memberships')), 'path')
    tree = {}
    for path in paths
      ptr = tree
      ptr = (ptr[element] ||= {}) for element in path
    tree

  pathContainsActiveControls: (path) ->
    @any (control) =>
      x = _.any(_.pluck(control.get('memberships'), 'path'), (mp) ->
        _.isEqual(path, mp.slice(0, path.length))) and control.isActive()


module.exports = [Control, Controls]
