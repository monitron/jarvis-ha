winston = require('winston')
_ = require('underscore')

module.exports = class Control
  defaults: # name and type are required
    options: {}
    connections: {}
    memberships: []

  # All commands must return a promise
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
    @log 'debug', "Executing command #{verb} with params: #{JSON.stringify(params)}"
    @commands[verb](this, params)

  log: (level, message) ->
    winston.log level, "[#{@_config.name} control] #{message}"

  toJSON: ->
    id: @id
    name: @_config.name
    type: @_config.type
    commands: _.keys(@commands)
    state: @getState()
    memberships: @_memberships
