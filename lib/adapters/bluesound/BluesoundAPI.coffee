Backbone = require('backbone')
Q = require('q')
xml2js = require('xml2js')
request = require('request')
winston = require('winston')

module.exports = class BluesoundAPI extends Backbone.Model
  fetchStatus: ->
    deferred = Q.defer()
    options = url: @url('Status')
    callback = (err, res, body) =>
      if err
        @log 'error', "Failed to request status: #{err}"
        deferred.reject err
      else
        xml2js.Parser().parseString body, (err, data) =>
          if err?
            @log 'error', "Failed to parse status XML: #{err}; #{body}"
            deferred.reject err
          else
            deferred.resolve data.status
    request options, callback
    deferred.promise

  setVolume: (level) ->
    @sendCommand 'Volume', {level: level}

  sendCommand: (resource, query) ->
    deferred = Q.defer()
    options = {url: @url(resource), qs: query}
    callback = (err, res, body) =>
      if err
        @log 'error', "Failed to send #{resource} command with query " +
          "#{JSON.stringify(query)}: #{err}"
        deferred.reject err
      else
        deferred.resolve()
    request options, callback
    deferred.promise

  url: (resource) ->
    "http://#{@get('host')}:11000/#{resource}"

  log: (level, message) ->
    winston.log level, "[BluesoundAPI] #{message}"
