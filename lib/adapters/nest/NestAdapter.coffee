
_ = require('underscore')
nest = require('unofficial-nest-api')
Adapter = require('../../Adapter')
NestThermostatNode = require('./NestThermostatNode')

module.exports = class NestAdapter extends Adapter
  name: "Nest"
  configDefaults: {}

  constructor: (config) ->
    super config
    @setValid false

  start: ->
    @log "debug", "Attempting Nest login"
    @nest = nest
    @nest.login @config.login, @config.password, (err, data) =>
      if err
        @log "error", "Couldn't log in to Nest (#{err.message})"
      else
        @log "debug", "Nest login success"
        @fetchStatus true

  fetchStatus: (initial = false) ->
    @log "debug", "Fetching status"
    @nest.fetchStatus (data) =>
      @processStatus(data)
      if initial then @discoverDevices()

  processStatus: (data) ->
    @log "debug", "Fetch status success"
    @_statusData = data

  discoverDevices: ->
    for deviceId, deviceStatus of @_statusData.device
      if _.has(deviceStatus, 'heater_source')
        # This appears to be a thermostat
        @addChild new NestThermostatNode(deviceId, this)
      else
        @log "debug", "Ignoring apparently non-thermostat device #{deviceId}"
    @setValid true
