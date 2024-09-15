Q = require('q')
_ = require('underscore')
[Capability] = require('../../Capability')
[MediaZone, MediaZones] = require('./MediaZone')

module.exports = class MediaCapability extends Capability
  name: "Media"

  defaults:
    zones: []

  commands:
    setZoneVolume: (capability, params) ->
      zone = capability.zones.get(params.zone)
      if !zone? or !zone.isValid()
        return Q.fcall(-> throw new Error("Missing or invalid zone"))
      volume = Number(params.volume)
      zone.setBasic('volume', volume)
    
    setZoneVolumeRelative: (capability, params) ->
      zone = capability.zones.get(params.zone)
      if !zone? or !zone.isValid()
        return Q.fcall(-> throw new Error("Missing or invalid zone"))
      prevVolume = zone.summarizeBasics().volume
      if !prevVolume?
        return Q.fcall(-> throw new Error("Current volume is unknown"))
      volumeDelta = Number(params.volumeDelta)
      zone.setBasic('volume', prevVolume + volumeDelta)

    setZonePower: (capability, params) ->
      zone = capability.zones.get(params.zone)
      if !zone? or !zone.isValid()
        return Q.fcall(-> throw new Error("Missing or invalid zone"))
      if _.isString(params.power) then params.power = params.power == 'true'
      zone.setBasic('powerOnOff', params.power)

    setZoneMute: (capability, params) ->
      zone = capability.zones.get(params.zone)
      if !zone? or !zone.isValid()
        return Q.fcall(-> throw new Error("Missing or invalid zone"))
      if _.isString(params.mute) then params.mute = params.mute == 'true'
      zone.setBasic('mute', params.mute)

    setZoneSource: (capability, params) ->
      zone = capability.zones.get(params.zone)
      if !zone? or !zone.isValid()
        return Q.fcall(-> throw new Error("Missing or invalid zone"))
      zone.powerOn().then =>
        zone.setBasic('mediaSource', params.source)

    sourcePlay: (capability, params) ->
      zone = capability.zones.get(params.zone)
      if !zone? or !zone.isValid()
        return Q.fcall(-> throw new Error("Missing or invalid zone"))
      zone.sourceCommand(params.source, 'play')

    sourcePause: (capability, params) ->
      zone = capability.zones.get(params.zone)
      if !zone? or !zone.isValid()
        return Q.fcall(-> throw new Error("Missing or invalid zone"))
      zone.sourceCommand(params.source, 'pause')

    sourceStop: (capability, params) ->
      zone = capability.zones.get(params.zone)
      if !zone? or !zone.isValid()
        return Q.fcall(-> throw new Error("Missing or invalid zone"))
      zone.sourceCommand(params.source, 'stop')

  start: ->
    @zones = new MediaZones(@get('zones'), {parent: this, server: @_server})
    @listenTo @zones, 'change', => @trigger 'change', this
    @setValid true

  _getState: ->
    zones: _.object(@zones.map((zone) -> [zone.id, zone.toStateJSON()]))

  toJSON: ->
    json = super
    json.zones = @zones.map((zone) -> zone.toJSON())
    json