
Backbone = require('backbone')
_ = require('underscore')
Q = require('q')

class Scene extends Backbone.Model
  initialize: ->
    @_server = @collection.server

  activate: ->
    if @isValid()
      promises = for command in @get('commands')
        @_server.controls.get(command.control).executeCommand(
          command.verb, command.parameters)
      Q.all(promises)
    else
      deferred = Q.defer()
      deferred.reject('One or more controls are missing or invalid')
      deferred.promise

  # This is a copy/paste from Control; it ought to be a mixin
  getMembership: (path) ->
    _.find(@get('memberships'), (membership) -> _.isEqual(membership.path, path))

  isValid: ->
    _.all(@get('commands'), (command) =>
      @_server.controls.get(command.control)?.isValid())

  log: (level, message) ->
    @_server.log level, "[#{@id} scene] #{message}"

  toJSON: ->
    _.extend super,
      valid: @isValid()

class Scenes extends Backbone.Collection
  model: Scene

  initialize: (models, options) ->
    @server = options?.server

  # This is a copy/paste from Control; it ought to be a mixin
  getPathTree: ->
    paths = _.pluck(_.flatten(@pluck('memberships')), 'path')
    tree = {}
    for path in paths
      ptr = tree
      ptr = (ptr[element] ||= {}) for element in path
    tree

  # This is a copy/paste from Control; it ought to be a mixin
  findMembersOfPath: (path) ->
    pairs = @map (control) ->
      control: control
      membership: control.getMembership(path)
    _.select(pairs, (p) -> p.membership?)


module.exports = [Scene, Scenes]