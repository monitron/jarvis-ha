Adapter = require('../../Adapter')
teslajs = require('teslajs')
TeslaVehicleNode = require('./TeslaVehicleNode')

module.exports = class TeslaAdapter extends Adapter
  name: 'Tesla'

  defaults:
    accounts: [] # tokens
    pollInterval:  300       # seconds between attempted vehicle data loads
    wakeInterval:  1800      # seconds beteen wake attempts on sleeping vehicle
    postWakePollInterval: 30 # seconds after wake attempt to load data
    postWakePollAttempts: 5  # times to try polling after wake attempt
    retryInterval: 300       # seconds after an error before trying again

  start: ->
    @setValid false
    @discoverVehicles(token) for token in @get('accounts')

  discoverVehicles: (token) ->
    @log 'verbose', "Discovering vehicles for #{token}"
    teslajs.vehicles {authToken: token}, (err, vehicles) =>
      if err?
        @log 'error', "Couldn't retrieve vehicles for #{token} (#{err})"
        setTimeout (=> @discoverVehicles(token)), @get('retryInterval')
      else
        for vehicle in vehicles
          attrs =
            id: vehicle.id_s
            authToken: token
            name: vehicle.display_name
            pollInterval: @get('pollInterval')
            wakeInterval: @get('wakeInterval')
            postWakePollInterval: @get('postWakePollInterval')
            postWakePollAttempts: @get('postWakePollAttempts')
          @log 'verbose', "Discovered vehicle #{attrs.id} (#{attrs.name})"
          @children.add new TeslaVehicleNode(attrs, {adapter: this})
        @setValid true