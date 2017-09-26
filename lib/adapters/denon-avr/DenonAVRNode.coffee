
[AdapterNode] = require('../../AdapterNode')
DenonAVRAPI = require('./DenonAVRAPI')

# Currently only supports the main zone
# Conspicuously missing any concept of sources

module.exports = class DenonAVRNode extends AdapterNode
  aspects:
    powerOnOff:
      commands:
        set: (node, value) ->
          node.setPower(value).then ->
            node.getAspect('powerOnOff').setData state: value
    volume:
      commands:
        set: (node, value) ->
          node.setVolume(value).then ->
            node.getAspect('volume').setData
              state: node.nearestSettableVolume(value)
    mute:
      commands:
        set: (node, value) ->
          node.setMute(value).then ->
            node.getAspect('mute').setData state: value

  initialize: ->
    super
    @setValid false
    @_api = new DenonAVRAPI(host: @get('host'))
    @updateStatus()
    setInterval((=> @updateStatus()), @adapter.get('pollInterval') * 1000)

  updateStatus: ->
    @_api.fetchMainZoneStatus()
      .then (data) =>
        @processData data
        @setValid true
      .fail (err) =>
        @log 'warn', "Failed to fetch status: #{err}"
        @setValid false
      .done()

  setPower: (power) ->
    @_api.sendCommand 'PW', if power then 'ON' else 'STANDBY'

  setVolume: (vol) ->
    @_api.sendCommand 'MV', @_api.percentageVolumeToCommand(vol)

  # Calculates what the observed volume will actually be after roundtrip
  nearestSettableVolume: (v) ->
    @_api.statusVolumeToPercentage(@_api.scalePercentageVolume(v) - 80)

  setMute: (mute) ->
    @_api.sendCommand 'MU', (if mute then 'ON' else 'OFF')

  processData: (data) ->
    @getAspect('powerOnOff').setData state: (data.Power[0].value[0] == 'ON')
    @getAspect('volume').setData
      state: @_api.statusVolumeToPercentage(data.MasterVolume[0].value[0])
    @getAspect('mute').setData state: (data.Mute[0].value[0] == 'on')
