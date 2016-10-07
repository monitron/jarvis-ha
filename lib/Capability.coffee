
Backbone = require('backbone')
_ = require('underscore')

# This is the generic Capability.
#
# Capabilities build on Adapters/Nodes/Controls by offering higher level
# control, monitoring and automation over multiple devices.
#
# A capability exposes a JSON blob representing its current status via the
# getState method. It also accepts commands through executeCommand.

class Capability extends Backbone.Model
  name: 'Negligent'
  defaults: {} # override with default configuration

  # All commands must return a promise
  commands: {}

  initialize: (attributes, options) ->
    @_server = options.server
    @_valid = false

  isEnabled: ->
    if @has('enabled') then @get('enabled') else true

  isValid: ->
    @_valid

  setValid: (@_valid) ->
    @log "debug", "Became #{if @_valid then 'valid' else 'invalid'}"

  start: ->
    @log "error", "Capability must override start method"

  executeCommand: (verb, params) ->
    @log 'debug', "Executing command #{verb} with params: #{JSON.stringify(params)}"
    @commands[verb](this, params)

  getState: ->
    if @isValid() then @_getState() else null

  _getState: ->
    {} # This is boring and you should probably override it

  log: (level, message) ->
    # Logs through the server because including winston breaks browserify
    @_server.log level, "[#{@name} capability] #{message}"

  toJSON: ->
    _.extend super,
      valid: @isValid()
      state: @getState()



class Capabilities extends Backbone.Collection
  model: Capability

module.exports = [Capability, Capabilities]