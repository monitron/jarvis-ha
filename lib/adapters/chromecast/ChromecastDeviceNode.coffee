_ = require('underscore')
Q = require('q')
Client = require('castv2-client').Client
DefaultMediaReceiver = require('castv2-client').DefaultMediaReceiver
[AdapterNode] = require('../../AdapterNode')

module.exports = class ChromecastDeviceNode extends AdapterNode
  aspects:
    mediaMetadata: {}
    mediaTransport:
      commands:
        play:  (node) -> node.sendAppCommand 'play'
        pause: (node) -> node.sendAppCommand 'pause'
        stop:  (node) -> node.sendAppCommand 'stop'
        seek:  (node, time) -> node.sendAppCommand 'seek', time
    volume:
      commands:
        set: (node, value) -> node.setVolume(value)
    mute:
      commands:
        set: (node, value) -> node.setMute(value)

  initialize: ->
    super
    @_connect()

  showSomething: (media) ->
    media ||=
      contentId: "https://i.redditmedia.com/xZ6cRasH3jBpCoyHwIJAWejhErwZHCD6ZvjS7_PbI0Y.jpg"
      contentType: "image/jpeg"
    @_client.launch DefaultMediaReceiver, (err, player) =>
      player.load media, {autoplay: true}, (e, s) => console.log s

  sendAppCommand: (command, arg...) ->
    deferred = Q.defer()
    if @_currentApp?
      callback = (err) ->
        if err? then deferred.reject('Command failed') else deferred.resolve()
      @_currentApp[command](arg..., callback)
    else
      deferred.reject 'No current media'
    deferred.promise

  setVolume: (level) ->
    deferred = Q.defer()
    callback = (err) ->
        if err? then deferred.reject('Command failed') else deferred.resolve()
    @_client.setVolume {level: (level / 100.0)}, callback
    deferred.promise

  setMute: (muted) ->
    deferred = Q.defer()
    callback = (err) ->
        if err? then deferred.reject('Command failed') else deferred.resolve()
    @_client.setVolume {muted: muted}, callback
    deferred.promise

  _connect: ->
    @log 'debug', "Connecting to #{@get('name')} at #{@get('address')}"
    @_client?.close()
    @_client = new Client()
    @_client.connect @get('address'), => @_onConnect()
    @_client.on 'error', (err) => @_onError(err)
    @_client.on 'status', (status) => @_onDeviceStatus(null, status)

  _onConnect: ->
    @log 'debug', "Connected to #{@get('name')}"
    @_client.getStatus @_onDeviceStatus.bind(this)

  _onDeviceStatus: (err, status) ->
    app = status?.applications?[0]
    if app? and @_currentApp?.receiverId != app.transportId
      @_currentAppName = app.displayName
      @getAspect('mediaTransport').setData {}
      @getAspect('mediaMetadata').setData {source: @_currentAppName}
      if _.findWhere(app.namespaces, name: 'urn:x-cast:com.google.cast.media')?
        @log 'debug', "Connecting to app #{app.displayName}"
        @_currentApp = new DefaultMediaReceiver(@_client.client, app)
        @_currentApp.on 'status', (status) => @_onMediaStatus(status)
        @_currentApp.getStatus (err, status) => @_onMediaStatus(status)
    if !app? and @_currentApp?
      delete @_currentApp
      delete @_currentAppName
      @getAspect('mediaTransport').setData {}
      @getAspect('mediaMetadata').setData {}
    if status?.volume?
      @getAspect('mute').setData state: status.volume.muted
      unless status.volume.muted # When muted, volume appears as 0..not helpful
        @getAspect('volume').setData state: status.volume.level * 100

  _onMediaStatus: (status) ->
    return unless status?
    @getAspect('mediaTransport').setData
      state: switch status.playerState
        when 'BUFFERING', 'PLAYING' then 'play'
        when 'IDLE' then 'idle'
        when 'PAUSED' then 'pause'
      buffering: status.playerState == 'BUFFERING'
      position: status.currentTime
    metadata = {source: @_currentAppName}
    if status.media?
      metadata.duration = status.media.duration
      if status.media.metadata?
        # also images (Array of URLs)
        metadata.title    = status.media.metadata.title
        metadata.subtitle = status.media.metadata.subtitle
    if status.media? or status.playerState == 'IDLE'
      @getAspect('mediaMetadata').setData metadata

  _onError: (err) ->
    @log 'warn', "Client error: #{err}"
    @_connect()