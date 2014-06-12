_ = require('underscore')
Backbone = require('backbone')


class Control extends Backbone.Model
  defaults: # name and type are required
    parameters: {}
    connections: {}
    memberships: []

  # All commands must return a promise
  commands: {}

  initialize: (attributes, options) ->
    @_server = options.server
    @_memberships = for membership in attributes.memberships
      _.extend(membership, path: membership.path)

  getConnectionTarget: (connId) ->
    path = @get('connections')[connId]
    return undefined unless path?
    @_server.getAdapterNode(path)

  getMembership: (path) ->
    _.find(@get('memberships'), (membership) -> _.isEqual(membership.path, path))

  executeCommand: (verb, params) ->
    @log 'debug', "Executing command #{verb} with params: #{JSON.stringify(params)}"
    @commands[verb](this, params)

  log: (level, message) ->
    @_server.log level, "[#{@get('name')} control] #{message}"

  toJSON: ->
    _.extend super,
      commands: _.keys(@commands)
      state: @getState()


class Controls extends Backbone.Collection
  model: Control

  findMembersOfPath: (path) ->
    pairs = @map (control) ->
      control: control
      membership: control.getMembership(path)
    _.select(pairs, (p) -> p.membership?)

  getPathTree: ->
    paths = _.pluck(_.flatten(@pluck('memberships')), 'path')
    tree = {}
    for path in paths
      ptr = tree
      ptr = (ptr[element] ||= {}) for element in path
    tree

module.exports = [Control, Controls]
