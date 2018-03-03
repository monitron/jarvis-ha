
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

  # Natural language commands
  naturalCommands: {}

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

  createEvent: (attrs, momentary = false) ->
    defaults = {sourceType: 'capability', sourceId: @id, start: new Date()}
    _.defaults(attrs, defaults)
    if momentary then attrs.end = attrs.start
    @log 'debug', "Adding event: #{JSON.stringify(attrs)}"
    @_server.events.add attrs # Returns the new event

  ongoingEvents: ->
    @_server.events.fromSource('capability', @id, true)

  getState: ->
    if @isValid() then @_getState() else null

  _getState: ->
    {} # This is boring and you should probably override it

  # Give a natural language command string, get an object mapping each
  # applicable command id to the calculated parameters needed to execute it
  naturalCommandCandidates: (input) ->
    candidates = {}
    for commandId, commandDetails of @naturalCommands
      for form in commandDetails.forms
        form = "^#{form}$" # Don't match partial commands
        tokens = form.match(/<(\w*)>/g) or []
        # Make any existing groups into nonmatching groups, then replace
        # parameter placeholders with matching groups
        template = form.replace(/\(/g, '(?:').replace(/<(\w*)>/g, "(.*)")
        match = input.match(template)
        if match?
          params = _.object(tokens.map((t) => t.slice(1, -1)), match.slice(1))
          resolved = if commandDetails.resolve?
            commandDetails.resolve(this, params)
          else
            {}
          if resolved? then candidates[commandId] = resolved
    candidates

  executeNaturalCommand: (command, params) ->
    @naturalCommands[command].execute(this, params)

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