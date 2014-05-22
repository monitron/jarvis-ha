
winston = require('winston')
_ = require('underscore')

module.exports = class Adapter
  name: "Negligent"
  configDefaults: {}

  constructor: (config) ->
    @config = _.defaults(config.base, @configDefaults)
    @devices = {}
    for id, deviceConfig of config.devices
      @devices[id] = @buildDevice(deviceConfig)

  start: ->
    @log "info", "#{@name} adapter starting"

  stop: ->
    @log "info", "#{@name} adapter stopping"

  buildDevice: ->
    @log "error", "buildDevice method must be overridden by #{@name} adapter"
    null

  log: (level, message) ->
    winston.log level, message