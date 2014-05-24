
NestDevice = require('./NestDevice')

module.exports = class NestThermostatDevice extends NestDevice
  aspects:
    thermostat:
      setTemperature: (temp) ->
        @adapter.nest.setTemperature @config.deviceId, temp

  do: (aspect, method, args...) ->
    @aspects[aspect][method].bind(this)(args...)