Backbone = require('backbone')
Q = require('q')
xml2js = require('xml2js')
request = require('request')
winston = require('winston')

module.exports = class DenonAVRAPI extends Backbone.Model
  fetchMainZoneStatus: ->
    deferred = Q.defer()
    options = url:
      "http://#{@get('host')}/goform/formMainZone_MainZoneXmlStatus.xml"
    callback = (err, res, body) =>
      if err
        @log 'error', "Main zone status request failed: #{err}"
        deferred.reject err
      else
        xml2js.Parser().parseString body, (err, data) =>
          if err?
            @log 'error', "Failed to parse status XML: #{err}; #{body}"
            deferred.reject err
          else
            deferred.resolve data.item
    request options, callback
    deferred.promise

  sendCommand: (command, param) ->
    deferred = Q.defer()
    options = url:
      "http://#{@get('host')}/goform/formiPhoneAppDirect.xml?#{command}#{param}"
    @log 'verbose', "Sending command #{command}#{param}"
    callback = (err, res, body) =>
      if err
        @log 'error', "Request of #{options.url} failed: #{err}"
        deferred.reject err
      else
        deferred.resolve()
    request options, callback
    deferred.promise

  scalePercentageVolume: (pct) ->
    (Math.round((pct / 100.0) * (98 * 2)) / 2.0)

  percentageVolumeToCommand: (pct) ->
    val = @scalePercentageVolume(pct)
    str = val.toString().replace('.', '')
    if val < 10 then "0#{str}" else str

  statusVolumeToPercentage: (vol) ->
    if vol == "--" then 0 else (Number(vol) + 80) / .98

  log: (level, message) ->
    winston.log level, "[DenonAVRAPI] #{message}"
