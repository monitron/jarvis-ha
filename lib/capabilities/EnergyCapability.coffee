_ = require('underscore')
[Capability] = require('../Capability')

module.exports = class EnergyCapability extends Capability
  name: "Energy"

  defaults:
    meters: {} # {meter: {sources: {period: [path], ...}, ...}, ...}
    idlePeriod: 'day'

  start: ->
    # Listen to all our sources
    for meterName, meterDetails of @get('meters')
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
          ((data[period] ||= {}).meters ||= {})[meterName] =
            aspect.getDatum('value')

    for period, periodData of data
      offsets = {}
      for offsetId, offset of @get('offsets')
        prod = periodData.meters[offset.productionMeter]
        cons = periodData.meters[offset.consumptionMeter]
        if prod? and cons? then offsets[offsetId] = prod / cons
      periodData.offsets = offsets
    data

  _getState: ->
    meters: @summarizeMeters()
