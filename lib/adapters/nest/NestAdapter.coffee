
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
        @log "debug", "Nest login success, doing fetchStatus"
        @nest.fetchStatus (data) => @processStatus(data)

  processStatus: (data) ->
    @log "debug", "Nest fetch status success"
    @setValid true
