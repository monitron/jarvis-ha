Backbone = require('backbone')
winston = require('winston')
request = require('request')
Q = require('q')

module.exports = class EcobeeAPI extends Backbone.Model
  defaults:
    baseURL: 'https://www.ecobee.com/home/'
    apiPath: '/api/1/'
    scope:   'smartWrite'

  initialize: ->

  connect: ->
    if @has('tokens')
      @log 'debug', "Using tokens to connect to API"
      @listThermostats().then => @trigger 'connected'
    else if @has('key')
      @log 'info', "No token; starting Ecobee PIN authorization!"
      @doPinAuthorization()
    else
      @log 'error', "No API key and no tokens. Giving up forever."

  listThermostats: ->
    deferred = Q.defer()
    body = selection:
      selectionType: 'registered'
      selectionMatch: null
      includeEquipmentStatus: true
      includeSensors: true
      includeRuntime: true
    @_apiCall('thermostat', 'GET', body)
      .then (body) =>
        thermostats = {}
        for thermostat in body.thermostatList
          thermostats[thermostat.identifier] = thermostat
        deferred.resolve thermostats
      .fail (err) =>
        deferred.reject err
    deferred.promise

  doPinAuthorization: ->
    data =
      client_id: @get('key')
      response_type: 'ecobeePin'
      scope: @get('scope')
    @_request('authorize', 'GET', data).then (body) =>
      @_pin = body # interval, code, ecobeePin
      @log 'info', "Your Ecobee PIN is --> #{@_pin.ecobeePin} <--"
      @log 'info', "Enter it on ecobee.com! Polling every #{@_pin.interval}s."
      setTimeout((=> @_checkPinAuthorization()), @_pin.interval * 1000)

  log: (level, message) ->
    winston.log level, "[EcobeeAPI] #{message}"

  _checkPinAuthorization: ->
    @log 'debug', "Polling PIN authorization..."
    data =
      client_id: @get('key')
      grant_type: 'ecobeePin'
      code: @_pin.code
    @_request('token', 'POST', data).then (body) =>
      if body.error == 'authorization_pending'
        @log 'info', "PIN not yet authorized. Please enter it on ecobee.com."
        setTimeout((=> @_checkPinAuthorization()), @_pin.interval * 1000)
      else if body.refresh_token?
        @log 'info', "PIN authorization success!"
        @set 'tokens', {access: body.access_token, refresh: body.refresh_token}
        @trigger 'connected'
      else
        @log 'error', "Unexpected PIN auth response: #{JSON.stringify(body)}"

  _apiCall: (resource, method = 'GET', body = {}, noRefresh = false) ->
    deferred = Q.defer()
    url = @get('apiPath') + resource
    data =
      body: JSON.stringify(body)
      token: @get('tokens').access
    @_request(url, method, data).then (response) =>
      switch response.status?.code
        when 0
          @log 'verbose', "#{method} #{url} succeeded"
          deferred.resolve response
        when 14 # Need refresh first
          @log 'verbose', 'Refreshing token'
          @_refreshBearerToken()
            .then => @_apiCall(resource, method, body, true)
            .then (r) => deferred.resolve r
            .fail (s) => deferred.reject s
        else
          @log 'debug', "#{method} #{url} failed: #{JSON.stringify(response)}"
          deferred.reject response.status
    deferred.promise

  _refreshBearerToken: ->
    deferred = Q.defer()
    @log 'verbose', 'Refreshing token'
    data =
      grant_type: 'refresh_token'
      code: @get('tokens').refresh
      client_id: @get('key')
    @_request('token', 'POST', data)
      .then (body) =>
        if body.access_token?
          @log 'verbose', 'Succeeded refreshing tokens'
          @set 'tokens', {access: body.access_token, refresh: body.refresh_token}
          deferred.resolve()
        else
          @log 'warn', 'Token refresh response did not contain access_token!'
          @log 'verbose', "Token refresh response: #{JSON.stringify(body)}"
          deferred.reject()
      .fail (err) =>
        @log 'warn', "Failed refreshing token: #{JSON.stringify(err)}"
        deferred.reject(err)
    deferred.promise

  _request: (resource, method = 'GET', data = {}) ->
    deferred = Q.defer()
    headers = {}
    if @_token?
      headers['Authorization'] = "Bearer #{@_token}"
    options =
      method: method
      url: @get('baseURL') + resource
      headers: headers
      json: true
    if method == 'GET' then options.qs = data
    @log 'verbose', "Making request: #{JSON.stringify(options)} with data #{JSON.stringify(data)}"
    callback = (err, res, body) =>
      if err
        @log 'error', "#{method} #{resource} failed: #{err}"
        deferred.reject err
      else
        deferred.resolve body
    req = request options, callback
    if method != 'GET' then req.form data
    deferred.promise
