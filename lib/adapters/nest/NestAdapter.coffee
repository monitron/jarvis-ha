
nest = require('unofficial-nest-api')
Adapter = require('../../Adapter')
NestThermostatDevice = require('./NestThermostatDevice')

module.exports = class NestAdapter extends Adapter
  name: "Nest"
  configDefaults: {}

  buildDevice: (config) ->
    switch config.type
      when 'thermostat' then new NestThermostatDevice(config, this)
      else null

  start: ->
    @log "debug", "Attempting Nest login"
    @nest = nest
    @nest.login @config.login, @config.password, (err, data) =>
      if err
        @log "error", "Couldn't log in to Nest (#{err.message})"
      else
        @log "debug", "Nest login success, doing fetchStatus"
        @nest.fetchStatus (data) =>
          @log "debug", "Nest fetch status success"