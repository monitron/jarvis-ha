
_ = require('underscore')
nest = require('unofficial-nest-api')
Adapter = require('../../Adapter')
NestThermostatNode = require('./NestThermostatNode')
Q = require('q')

module.exports = class NestAdapter extends Adapter
  name: "Nest"
  configDefaults: {}

  constructor: (config) ->
    super config
    @setValid false
    @hasDiscovered = false

  start: ->
    @log "debug", "Attempting Nest login"
    @_nest = nest
    @_nest.login @config.login, @config.password, (err, data) =>
      if err
        @log "error", "Couldn't log in to Nest (#{err.message})"
      else
        @log "debug", "Nest login success"
        @refreshData()

  refreshData: ->
    @log "debug", "Fetching status"
    deferred = Q.defer()
    # XXX If an error occurs, nest just never calls us back
    @_nest.fetchStatus (data) =>
      @log "debug", "Fetch status success"
      @_statusData = data
      unless @hasDiscovered then @discoverDevices()
      @deliverData()
      deferred.resolve()
    deferred.promise

  deliverData: ->
    for id in @getChildIds()
      @getChild(id).processData
        "current-humidity":    @_statusData.device[id]["current_humidity"]
        "target-temperature":  @_statusData.shared[id]["target_temperature"]
        "current-temperature": @_statusData.shared[id]["current_temperature"]
        "target-type":         @_statusData.shared[id]["target_temperature_type"]

  discoverDevices: ->
    for deviceId, deviceStatus of @_statusData.device
      if _.has(deviceStatus, 'heater_source')
        # This appears to be a thermostat
        @log "debug", "Discovered apparent thermostat #{deviceId}"
        @addChild new NestThermostatNode(deviceId, this)
      else
        @log "debug", "Ignoring apparently non-thermostat device #{deviceId}"
    @hasDiscovered = true
    @setValid true

  setTemperature: (deviceId, temp) ->
    @_nest.setTemperature deviceId, temp
    Q.fcall(-> true) # XXX Super duper lame. nest lib returns nothing
