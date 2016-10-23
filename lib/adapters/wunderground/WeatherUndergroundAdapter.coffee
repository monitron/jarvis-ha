
Q = require('q')
request = require('request')

Adapter = require('../../Adapter')
WeatherUndergroundStationNode = require('./WeatherUndergroundStationNode')

module.exports = class WeatherUndergroundAdapter extends Adapter
  name: "Weather Underground"

  defaults:
    stations: []  # specify a zip code, or a PWS name like pws:KCATAHOE2
    interval: 300 # seconds; defaults to every five minutes
    # an apiKey must be specified; see https://www.wunderground.com/weather/api

  initialize: ->
    super
    @setValid false

  start: ->
    unless @has('apiKey')
      @log 'error', "No apiKey specified; cannot continue!"
    else
      for station in @get('stations')
        @children.add new WeatherUndergroundStationNode(
          {id: station}, {adapter: this})
        setInterval (=> @fetch()), @get('interval') * 1000
        @fetch() # Initial fetch
      @setValid true

  fetch: ->
    @fetchStation(station) for station in @get('stations')

  fetchStation: (station) ->
    @log 'verbose', "Fetching station #{station}"
    @request(['conditions'], station)
      .then (data) => @children.get(station).processData data

  request: (features, location) ->
    deferred = Q.defer()
    url = "http://api.wunderground.com/api/#{@get('apiKey')}/" +
      "#{features.join('/')}/q/#{location}.json"
    request {url: url}, (err, res, body) =>
      if err?
        @log 'warn', "Failed to fetch #{url} (#{err})"
        deferred.reject err
      else
        deferred.resolve JSON.parse(body)
    deferred.promise
