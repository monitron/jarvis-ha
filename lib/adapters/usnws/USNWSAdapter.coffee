
Adapter = require('../../Adapter')
xml2js = require('xml2js')
request = require('request')
USNWSStationNode = require('./USNWSStationNode')

module.exports = class USNWSAdapter extends Adapter
  name: "US National Weather Service"

  defaults:
    stations: []
    interval: 1800 # seconds; defaults to half an hour

  start: ->
    for station in @get('stations')
      @children.add new USNWSStationNode({id: station}, {adapter: this})
    setInterval (=> @fetchConditions()), @get('interval') * 1000
    @fetchConditions() # Initial fetch

  fetchConditions: ->
    @fetchConditionsForStation(station) for station in @get('stations')

  fetchConditionsForStation: (station) ->
    @log 'verbose', "Fetching conditions for #{station}"
    requestOptions =
      url: "http://w1.weather.gov/xml/current_obs/#{station}.xml"
      headers:
        'User-Agent': 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0'

    request requestOptions, (err, res, body) =>
      if err?
        @log 'warn', "Failed to fetch XML for #{station} (#{err})"
        return
      xml2js.Parser().parseString body, (err, data) =>
        if err?
          @log 'warn', "Failed to parse XML for #{station} (#{err})"
          return
        try
          conditions = data.current_observation
          data =
            temperature: parseFloat(conditions.temp_c[0])
            humidity:    parseInt(conditions.relative_humidity[0])
            description: conditions.weather[0]
          # TODO: wind_mph(float), wind_degrees(int), pressure_in(float)...
          @children.get(station).processData data
        catch e
          @log 'warn', "Failed to scrape conditions for #{station} (#{e})"
