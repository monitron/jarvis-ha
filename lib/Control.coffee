_ = require('underscore')

module.exports = class Control
  defaults: # name and type are required
    options: {}
    connections: {}
    memberships: []

  constructor: (@_server, config) ->
    @_config = _.defaults(config, @defaults)
    @_memberships = for membership in @_config.memberships
      _.extend(membership, path: @_server.normalizePath(membership.path))

  getConnectionTarget: (connId) ->
    path = @config.connections[connId]
    return undefined unless path?
    @_server.getAdapterNode(path)

  getMembership: (path) ->
    _.find(@_memberships, (membership) -> _.isEqual(membership.path, path))
