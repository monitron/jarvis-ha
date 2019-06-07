
BluesoundAPI = require('./BluesoundAPI')
[AdapterNode] = require('../../AdapterNode')

module.exports = class BluesoundNode extends AdapterNode
  aspects:
    mediaMetadata: {}
    mediaTransport:
      commands:
        play: (node) -> node.api.sendCommand 'Play'
        pause: (node) -> node.api.sendCommand 'Pause'
        stop: (node) -> node.api.sendCommand 'Stop'
        seek: (node, time) -> node.api.sendCommand 'Play', seek: time
    volume:
      commands:
        set: (node, value) ->
          node.api.setVolume(value).then ->
            node.getAspect('volume').setData state: value

  initialize: ->
    super
    @setValid false
    @api = new BluesoundAPI(host: @get('host'))
    @updateStatus()
    setInterval((=> @updateStatus()), @adapter.get('pollInterval') * 1000)

  updateStatus: ->
    @api.fetchStatus()
      .then (data) =>
        @processData data
        @setValid true
      .fail (err) =>
        @log 'warn', "Failed to fetch status: #{err}"
        @setValid false
      .done()

  processData: (data) =>
    @getAspect('volume').setData state: Number(data.volume[0])
    @getAspect('mediaMetadata').setData
      source:   data.inputId?[0]
      duration: if data.totlen? then Number(data.totlen[0])
      title:    data.title1?[0]
      subtitle: data.title2?[0]
    if data.inputId?
      @getAspect('mediaTransport').setData
        state: switch data.state[0]
          when 'stream', 'play' then 'play'
          when 'pause' then 'pause'
          when 'stop' then 'idle'
        position: Number(data.secs[0])
    else
      @getAspect('mediaTransport').setData {}