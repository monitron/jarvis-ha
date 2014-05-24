
winston = require('winston')
Node = require('./Node')
_ = require('underscore')

module.exports = class Adapter extends Node
  name: "Negligent"
  configDefaults: {}

  constructor: (config) ->
    super 'root', this
    @config = _.defaults(config, @configDefaults)

  start: ->
    @log "error", "start method must be overridden by #{@name} adapter"

  log: (level, message) ->
    winston.log level, "[#{@name} adapter] #{message}"