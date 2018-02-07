Q = require('q')
request = require('request')

Adapter = require('../../Adapter')
FoobotDeviceNode = require('./FoobotDeviceNode')

module.exports = class FoobotAdapter extends Adapter
  name: "Foobot"

  defaults:
    interval: 600 # seconds; defaults to every ten minutes. Note that there is
                  # a limit of 200 requests per day. If you request more than
                  # once every 8 minutes or so, you'll run out. If you have
                  # two Foobots, you'll need to wait ~15 minutes. :(
    # must specify apiKey (string) and username (string - probably your email)
    # see http://api.foobot.io/apidoc/index.html

  initialize: ->
    super
    @setValid false

  start: ->
    unless @has('apiKey') and @has('username')
      @log 'error', "Cannot continue without apiKey and username"
    else
      @discoverDevices()

  discoverDevices: ->
    @request("owner/#{@get('username')}/device/")
      .then (data) =>
        for device in data
          @log 'verbose', "Discovered Foobot '#{device.name}' (#{device.uuid})"
          @children.add new FoobotDeviceNode(
            {id: device.uuid, name: device.name}, {adapter: this})
        setInterval (=> @fetchAll()), @get('interval') * 1000
        @fetchAll()
        @setValid true
      .fail (err) =>
        @log 'error', "Failed to discover Foobot devices. Giving up."
      .done()

  fetchAll: ->
    @children.each (child) => child.fetch()

  request: (path, params = {}) ->
    deferred = Q.defer()
    options =
      url: "http://api.foobot.io/v2/" + path
      headers: {"X-API-KEY-TOKEN": @get('apiKey')}
      qs: params
    request options, (err, res, body) =>
      if err?
        @log 'warn', "Failed to fetch #{url} (#{err})"
        deferred.reject err
      else
        try
          deferred.resolve JSON.parse(body)
        catch err
          @log 'warn', "Request (#{url}) resulted in JSON parse error: #{err}"
          deferred.reject err
    deferred.promise
