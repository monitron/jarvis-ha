_ = require('underscore')
DarkSky = require('dark-sky')
Adapter = require('../../Adapter')
DarkSkyLocationNode = require('./DarkSkyLocationNode')

module.exports = class DarkSkyAdapter extends Adapter
  name: "Pirate Weather"

  defaults:
    interval: 200 # seconds; defaults to every 3.33 minutes
    locations: {}
    narrativeLanguage: "en"
    narrativeUnits: "auto"
    # must specify apiKey and locations {name: [lat, lng]}
    # Please see https://darksky.net/dev

  initialize: ->
    super
    @setValid false

  start: ->
    unless @has('apiKey')
      @log 'error', "No apiKey specified"
      return
    locations = @get('locations')
    unless _.isObject(locations) and Object.keys(locations).length > 0
      @log 'error', "No (or invalid) locations specified"
      return
    @api = new DarkSky(@get('apiKey'))
    for locationKey, location of locations
      @children.add new DarkSkyLocationNode(
        {
          id: locationKey,
          interval: @get('interval'),
          narrativeLanguage: @get('narrativeLanguage'),
          narrativeUnits: @get('narrativeUnits'),
          location: location
        },
        {adapter: this})
    @setValid true