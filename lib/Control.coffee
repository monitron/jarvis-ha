
Q = require('q')
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
    if @_server?
      transitionEventually = _.debounce((=> @handleStateTransition()), 100)
      @_prevState = @getState()
      # Notice when our connections' data changes
      for path in @getUniqueConnectionPaths()
        @_server.adapters.onEventAtPath path, 'aspectData:change', =>
          @_beginTransitionState ||= @_prevState
          @_prevState = @getState()
          @trigger 'change', this
          transitionEventually()
        # Notice when our connections become valid (or invalid)
        @_server.adapters.onEventAtPath path, 'valid:change', =>
          @_prevState = @getState()
          @trigger 'change', this

  isValid: ->
    _.every @getUniqueConnectionPaths(), (path) =>
      p = @_server.adapters.getPath(path)
      unless p? then @log 'warn', "Path #{path} is missing"
      p? and p.isValid()

  getConnectionTarget: (connId) ->
    path = @get('connections')[connId]
    return undefined unless path?
    @_server.adapters.getPath(path)

  getUniqueConnectionPaths: ->
    uniquePaths = []
    for path in _.values(@get('connections'))
      uniquePaths.push(path) unless _.find(uniquePaths, (p) -> _.isEqual(p, path))
    uniquePaths

  getUniqueMembershipPaths: ->
    _.uniq(_.pluck(@get('memberships'), 'path'))

  getDefaultMembershipPath: (prefix = []) ->
    _.find @getUniqueMembershipPaths(),
      (path) -> _.isEqual(path.slice(0, prefix.length), prefix)

  getMembership: (path) ->
    _.find(@get('memberships'), (membership) -> _.isEqual(membership.path, path))

  executeCommand: (verb, params) ->
    if @isValid()
      command = @commands[verb]
      description = "#{verb} with params #{JSON.stringify(params)}"
      if command.wouldHaveEffect(params, @_getState())
        @log 'debug', "Executing command #{description}"
        @commands[verb].execute(this, params)
      else
        @log 'debug', "Not executing command with no effect: #{description}"
    else
      @log 'warn', "Ignoring #{verb} command; control not currently valid"
      Q.fcall(-> throw new Error("Invalid"))

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

  # Override me with a function that generates English from a pair of state
  # objects (old and new). The return should be a past-tense phrase which can
  # follow "{name of control}"
  # Both states are guaranteed to be non-null and different
  # By default, no state transitions will be recorded (null)
  describeStateTransition: (oldState, newState) ->
    null

  handleStateTransition: ->
    oldState = @_beginTransitionState
    delete @_beginTransitionState
    newState = @getState()
    if oldState? and newState? and !_.isEqual(oldState, newState)
      desc = @describeStateTransition(oldState, newState)
      if desc? then @_server.events.add
        sourceType: 'control'
        sourceId:   @id
        start:      new Date()
        end:        new Date()
        importance: 'routine'
        title:      desc

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

  selectWithFilters: (filters) ->
    @select (ctrl) ->
      for filter in filters
        result = switch filter.type
          when 'ids'        then _.contains(filter.value, ctrl.id)
          when 'valid'      then ctrl.isValid()
          when 'active'     then ctrl.isActive()
          when 'hasCommand' then ctrl.hasCommand(filter.value)
          when 'memberOf'   then ctrl.getMembership(filter.value)?
        return false unless result
      true

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
