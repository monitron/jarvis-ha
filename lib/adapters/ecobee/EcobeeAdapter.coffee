
EcobeeAPI = require('./EcobeeApi')
Adapter = require('../../Adapter')
EcobeeThermostatNode = require('./EcobeeThermostatNode')

module.exports = class EcobeeAdapter extends Adapter
  name: "Ecobee"

  initialize: ->
    super
    @setValid false

  start: ->
    @getPersistentData('tokens').then (tokens) =>
      @log 'verbose', "Initial Tokens = #{JSON.stringify(tokens)}"
      @_api = new EcobeeAPI(key: @get('apiKey'), tokens: tokens)
      @listenTo @_api, 'connected', => @discoverThermostats()
      @listenTo @_api, 'change:tokens', (m, value) =>
        @log 'verbose', "New Tokens = #{JSON.stringify(value)}"
        @setPersistentData 'tokens', value
      @log 'debug', 'Authenticating to Ecobee API'
      @_api.connect()

  discoverThermostats: ->
    @_api.listThermostats()
      .then (thermostats) =>
        for id, thermostat of thermostats
          @log 'verbose', "Thermostat ID #{id} enumerated"
          @children.add new EcobeeThermostatNode({id: id}, {adapter: this})
        @setValid true
      .fail (err) =>
        @log 'error', "Could not discover thermostats (#{err})"