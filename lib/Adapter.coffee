
winston = require('winston')
Node = require('./Node')
_ = require('underscore')

module.exports = class Adapter extends Node
  name: "Negligent"
  configDefaults: {}

  constructor: (config) ->
    super 'root', this
    @config = _.defaults(config, @configDefaults)

  log: (level, message) ->
    winston.log level, "[#{@name} adapter] #{message}"

  start: ->
    @log "error", "Adapter must override start method"

  refreshData: ->
    @log "error", "Adapter must override refreshData method"