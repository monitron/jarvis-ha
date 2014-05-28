_ = require('underscore')

module.exports = class Control
  defaults: # name and type are required
    options: {}
    connections: {}
    memberships: []

  constructor: (@_server, config) ->
    @config = _.defaults(config, @defaults)
    @config.memberships = for path in @config.memberships
      if _.isString(path) then path.split('/') else path

  getConnectionTarget: (connId) ->
    path = @config.connections[connId]
    return undefined unless path?
    @_server.getAdapterNode(path)

  isMemberOf: (sought) ->
    _.some(@config.memberships, (path) -> _.isEqual(path, sought))