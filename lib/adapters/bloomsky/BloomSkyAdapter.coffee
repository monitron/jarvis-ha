
Adapter = require('../../Adapter')
request = require('request')
Q = require('q')
BloomSkyDeviceNode = require('./BloomSkyDeviceNode')

# Specify an apiKey configuration parameter
# which you can get from https://dashboard.bloomsky.com/
# (click on the Developers link)

module.exports = class BloomSkyAdapter extends Adapter
  name: 'BloomSky'

  defaults:
    pollInterval: 300 # Seconds between data reloads

  start: ->
    @children.add new BloomSkyDeviceNode({id: 'device'},
      {adapter: this})
    setInterval((=> @poll()), @get('pollInterval') * 1000)
    @poll()

  poll: ->
    @_request().then (res) =>
      @children.get('device').processData(res[0].Data)

  _request: ->
    deferred = Q.defer()
    requestOptions =
      url: "https://api.bloomsky.com/api/skydata/"
      qs: {unit: 'intl'}
      headers: {Authorization: @get('apiKey')}
    request requestOptions, (err, res, body) =>
      if err?
        @log 'warn', "Request failed: #{err}"
        deferred.reject err
      else
        try
          deferred.resolve JSON.parse(body)
        catch err
          @log 'warn', "JSON parse error: #{err}"
          deferred.reject err
    deferred.promise
