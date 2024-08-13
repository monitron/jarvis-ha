
[AdapterNode] = require('../../AdapterNode')
Q = require('q')

module.exports = class DenonAVRNode extends AdapterNode
  aspects:
    mediaTransport:
      commands:
        play:  (node) -> node.doPromiseCommand("play")
        pause: (node) -> node.doPromiseCommand("pause")
        stop:  (node) -> node.doPromiseCommand("stop")
    mediaMetadata: {}

  initialize: ->
    super
    @setValid false
    @_api = @get('device')
    @getState()
    @_state = {}
    @_api.on 'update', (event) =>
      if event instanceof Error
        @log 'warning', event
        return
      if event.key == 'dateTime'
        return
      @_state[event.key] = event.value
      @processData @_state
  
  doPromiseCommand: (cmdName) ->
    deferred = Q.defer()
    @_api[cmdName]()
      .then => deferred.resolve()
      .catch (err) => deferred.reject(err)
    deferred.promise
  
  getState: ->
    @_api.getState()
      .then (state) =>
        @_state = state
        @processData state
        @setValid true
      .catch (e) => @log 'warning', e

  processData: (state) =>
    @getAspect('mediaTransport').setData
      state: switch state.deviceState
        when 'playing', 'loading', 'seeking' then 'play'
        when 'idle' then 'idle'
        when 'paused', 'stopped' then 'pause'
    @getAspect('mediaMetadata').setData
      source: state.app
      title: state.title
      subtitle: state.artist