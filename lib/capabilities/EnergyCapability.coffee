_ = require('underscore')
[Capability] = require('../Capability')

module.exports = class EnergyCapability extends Capability
  name: "Energy"

  defaults:
    meters: {} # {meter: {sources: {period: [path], ...}, ...}, ...}
    energyPrecision: 1
    idlePeriod: 'day'

  start: ->
    # Listen to all our sources
    for meterName, meterDetails in @get('meters')
      for period, path of meterDetails.sources
        @_server.adapters.onEventAtPath path,
          'aspectData:change', => @trigger 'change', this
    @setValid true # XXX Notice if source adapter becomes invalid

  summarizeMeters: ->
    data = {}
    for meterName, meterDetails of @get('meters')
      for period, path of meterDetails.sources
        aspect = @_server.adapters.getPath(path)?.getAspect('energySensor')
        if aspect?
          (data[period] ||= {})[meterName] = aspect.getDatum('value')
    data

  toJSON: ->
    _.extend super,
      meterSummary: @summarizeMeters()