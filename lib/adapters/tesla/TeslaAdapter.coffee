Adapter = require('../../Adapter')
teslajs = require('teslajs')
TeslaVehicleNode = require('./TeslaVehicleNode')

module.exports = class TeslaAdapter extends Adapter
  name: 'Tesla'

  defaults:
    accounts: []             # { email, password }
    pollInterval:  300       # seconds between attempted vehicle data loads
    wakeInterval:  3600      # seconds beteen wake attempts on sleeping vehicle
    postWakePollInterval: 30 # seconds after wake attempt to load data
    postWakePollAttempts: 5  # times to try polling after wake attempt
    retryInterval: 300       # seconds after an error before trying again

  start: ->
    @setValid false
    @login(account) for account in @get('accounts')

  login: (account) ->
    @log 'verbose', "Logging in to #{account.email}"
    teslajs.login account.email, account.password, (err, result) =>
      if err?
        @log 'error', "Couldn't log in to #{account.email}, giving up (#{err})"
      else
        # XXX Does not make use of refresh token; will crap out after 2 months
        @discoverVehicles result.authToken

  discoverVehicles: (token) ->
    teslajs.vehicles {authToken: token}, (err, vehicles) =>
      if err?
        @log 'error', "Couldn't retrieve vehicles (#{err})"
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