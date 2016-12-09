
Adapter = require('../../Adapter')
request = require('request')
SolarCityMeterNode = require('./SolarCityMeterNode')
Q = require('q')
moment = require('moment')

# To get your customer and installation values for configuration:
# 1. Log into mysolarcity.com
# 2. Visit PowerGuide
# 3. Click the Share button in the top left and copy the link
# 4. Visit the Share link in a new browser tab
# 5. Open a JavaScript console
# 6. Type:
#    window.appConfig.DefaultInstallationGUID
#    window.appConfig.CustomerGUID

module.exports = class SolarCityAdapter extends Adapter
  name: "SolarCity"
  timeFormat: 'YYYY-MM-DDTHH:mm:ss' # ISO8601 w/o TZ

  defaults:
    pollInterval: 300 # Seconds between data reloads

  start: ->
    for variable in ['consumption', 'production']
      for period in ['today', 'this-month', 'this-year']
        @children.add new SolarCityMeterNode({id: "#{variable}-#{period}"},
          {adapter: this})
    setInterval((=> @poll()), @get('pollInterval') * 1000)
    @poll()

  poll: ->
    now = moment()
    options =
      StartTime: now.startOf('day').format(@timeFormat)
      EndTime:   now.endOf('day').format(@timeFormat)
      Period:    'Hour'
    @_pollInterval options, 'today'
    options =
      StartTime: now.startOf('month').format(@timeFormat)
      EndTime:   now.endOf('month').format(@timeFormat)
      Period:    'Day'
    @_pollInterval options, 'this-month'
    options =
      StartTime: now.startOf('year').format(@timeFormat)
      EndTime:   now.endOf('year').format(@timeFormat)
      Period:    'Month'
    @_pollInterval options, 'this-year'

  _pollInterval: (options, interval) ->
    @_request('consumption', options).then (res) =>
      @children.get("consumption-#{interval}").processData(
        res.TotalConsumptionInIntervalkWh)
    options = Object.assign({IsByDevice: true}, options)
    @_request('measurements', options).then (res) =>
      @children.get("production-#{interval}").processData(
        res.TotalEnergyInIntervalkWh)

  _request: (type, options) ->
    deferred = Q.defer()
    requestOptions =
      url: "https://mysolarcity.com/solarcity-api/powerguide/v1.0/" +
        "#{type}/#{@get('installation')}"
      qs: Object.assign({ID: @get('customer')}, options)
    request requestOptions, (err, res, body) =>
      if err?
        @log 'warn', "Request (#{type}) failed: #{err}"
        deferred.reject err
      else
        try
          deferred.resolve JSON.parse(body)
        catch err
          @log 'warn', "Request (#{type}) resulted in JSON parse error: #{err}"
          deferred.reject err
    deferred.promise
