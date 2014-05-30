_ = require('underscore')

module.exports = class Control
  defaults: # name and type are required
    options: {}
    connections: {}
    memberships: []

  commands: {}

  constructor: (@_server, config) ->
    @_config = _.defaults(config, @defaults)
    @id = @_config.id
    @_memberships = for membership in @_config.memberships
      _.extend(membership, path: @_server.normalizePath(membership.path))

  getConnectionTarget: (connId) ->
    path = @_config.connections[connId]
    return undefined unless path?
    @_server.getAdapterNode(path)

  getMembership: (path) ->
    _.find(@_memberships, (membership) -> _.isEqual(membership.path, path))

  executeCommand: (verb, params) ->
    @commands[verb](this, params)

  toJSON: ->
    id: @id
    name: @_config.name
    type: @_config.type
