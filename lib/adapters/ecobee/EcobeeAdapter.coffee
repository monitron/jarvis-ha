
EcobeeAPI = require('./EcobeeAPI')
Adapter = require('../../Adapter')
EcobeeThermostatNode = require('./EcobeeThermostatNode')
EcobeeSensorNode = require('./EcobeeSensorNode')

module.exports = class EcobeeAdapter extends Adapter
  name: "Ecobee"

  defaults:
    pollInterval: 300 # seconds between data refreshes; defaults to every 5min

  initialize: ->
    super
    @setValid false

  start: ->
    @getPersistentData('tokens').then (tokens) =>
      @log 'verbose', "Initial Tokens = #{JSON.stringify(tokens)}"
      @_api = new EcobeeAPI(key: @get('apiKey'), tokens: tokens)
      @listenTo @_api, 'connected', =>
        @pollThermostats()
        setInterval (=> @pollThermostats()), @get('pollInterval') * 1000
      @listenTo @_api, 'change:tokens', (m, value) =>
        @log 'verbose', "New Tokens = #{JSON.stringify(value)}"
        @setPersistentData 'tokens', value
      @log 'debug', 'Authenticating to Ecobee API'
      @_api.connect()

  pollThermostats: ->
    @log 'debug', 'Polling thermostats...'
    @_api.listThermostats()
      .then (thermostats) =>
        for id, thermostat of thermostats
          node = @children.get(id)
          unless node?
            @log 'verbose', "Creating thermostat ID #{id}"
            @children.add new EcobeeThermostatNode({id: id}, {adapter: this})
          for sensor in thermostat.remoteSensors
            snode = @children.get(sensor.id)
            unless snode?
              @log 'verbose', "Creating sensor ID #{sensor.id} (#{sensor.name})"
              snode = @children.add(
                new EcobeeSensorNode({id: sensor.id}, {adapter: this}))
            snode.processData sensor
        @setValid true
      .fail (err) =>
        @log 'error', "Could not discover thermostats (#{err})"