
NestNode = require('./NestNode')

module.exports = class NestThermostatNode extends NestNode
  aspects:
    thermostat:
      setTemperature: (temp) ->
        @adapter.nest.setTemperature @config.deviceId, temp

  do: (aspect, method, args...) ->
    @aspects[aspect][method].bind(this)(args...)