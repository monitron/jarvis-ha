_ = require('underscore')
[Capability] = require('../../Capability')
[MediaZone, MediaZones] = require('./MediaZone')

module.exports = class MediaCapability extends Capability
  name: "Media"

  defaults:
    zones: []

  commands:
    setZoneVolume: (capability, params) ->
      volume = Number(params.volume)
      capability.zones.get(params.zone).setBasic('volume', volume)

    setZonePower: (capability, params) ->
      if _.isString(params.power) then params.power = params.power == 'true'
      capability.zones.get(params.zone).setBasic('powerOnOff', params.power)

    setZoneMute: (capability, params) ->
      if _.isString(params.mute) then params.mute = params.mute == 'true'
      capability.zones.get(params.zone).setBasic('mute', params.mute)

    setZoneSource: (capability, params) ->
      capability.zones.get(params.zone).setBasic('mediaSource', params.source)

  start: ->
    @zones = new MediaZones(@get('zones'), {parent: this, server: @_server})
    @listenTo @zones, 'change', => @trigger 'change', this
    @setValid true

  _getState: ->
    zones: _.object(@zones.map((zone) -> [zone.id, zone.toStateJSON()]))