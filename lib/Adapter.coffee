
winston = require('winston')
[AdapterNode] = require('./AdapterNode')
_ = require('underscore')

module.exports = class Adapter extends AdapterNode
  name: "Negligent"
  defaults: {}

  log: (level, message) ->
    winston.log level, "[#{@name} adapter] #{message}"

  isEnabled: ->
    if @has('enabled') then @get('enabled') else true

  start: ->
    @log "error", "Adapter must override start method"

  refreshData: ->
    @log "error", "Adapter must override refreshData method"