
[AdapterNode] = require('../../AdapterNode')
DenonAVRAPI = require('./DenonAVRAPI')

# Currently only supports the main zone

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
    mediaSource:
      commands:
        set: (node, value) ->
          node.setInput(value).then ->
            node.getAspect('mediaSource').setData state: value

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
    maxVol = @get("maxVolume")
    if maxVol?
      vol = vol * (maxVol / 100)
    @_api.sendCommand 'MV', @_api.percentageVolumeToCommand(vol)

  setInput: (input) ->
    @_api.sendCommand 'SI', input

  # Calculates what the observed volume will actually be after roundtrip
  nearestSettableVolume: (v) ->
    @_api.statusVolumeToPercentage(@_api.scalePercentageVolume(v) - 80)

  setMute: (mute) ->
    @_api.sendCommand 'MU', (if mute then 'ON' else 'OFF')

  processData: (data) ->
    maxVol = @get("maxVolume")
    volume = @_api.statusVolumeToPercentage(data.MasterVolume[0].value[0])
    if maxVol?
      volume = Math.min(volume * (100 / maxVol), 100)
    @getAspect('powerOnOff').setData state: (data.Power[0].value[0] == 'ON')
    @getAspect('volume').setData state: volume
    @getAspect('mute').setData state: (data.Mute[0].value[0] == 'on')
    @getAspect('mediaSource').setData state: data.InputFuncSelect[0].value[0]
