
_ = require('underscore')
Q = require('q')
harmony = require('harmonyhubjs-client')

[AdapterNode] = require('../../AdapterNode')

module.exports = class HarmonyHubNode extends AdapterNode
  powerOffActivityId: '-1' # This activity signifies the system is off

  aspects:
    mediaSource:
      commands:
        set: (node, value) ->
          node.startActivity(value).then ->
            node.getAspect('powerOnOff').setData  state: true
            node.getAspect('mediaSource').setData state: value
      events:
        changed: (prev, cur) -> prev.state != cur.state
    powerOnOff:
      commands:
        set: (node, value) ->
          return if value # Turning on isn't meaningful
          node.turnOff().then ->
            node.getAspect('powerOnOff').setData  state: false
            node.getAspect('mediaSource').setData state: null
      events:
        changed: (prev, cur) -> prev.state != cur.state

  initialize: ->
    super
    @setValid false
    promise = harmony(@get('host'))
    promise.catch (error) =>
      @log "error", "Failed to connect to Harmony (#{error})"
    promise.then (client) =>
      @log "debug", "Connected to Harmony"
      @_harmony = client
      @discoverActivities()
      @_keepalive = setInterval((=> @pollCurrentActivity()),
        @get('keepaliveInterval') * 1000)
      @_harmony._xmppClient.on 'stanza', (s) => @_processXMPPMessage(s)
    promise.done()

  discoverActivities: ->
    @log "debug", "Discovering activities..."
    promise = @_harmony.getActivities()
    promise.catch (error) =>
      @log "error", "Failed to discover activities (#{error})"
    promise.then (activities) =>
      activityMap = {}
      # Fun fact: activity IDs are strings and must stay that way
      (activityMap[activity.id] = activity.label) for activity in activities
      @log "debug", "Discovered #{_.size(activityMap)} activities"
      @getAspect('mediaSource').setAttribute 'choices',
        _.omit(activityMap, @powerOffActivityId)
      @pollCurrentActivity().then => @setValid(true) # Get initial state
    promise.done()

  pollCurrentActivity: ->
    deferred = Q.defer()
    @log "verbose", "Polling current activity..."
    if @_pollWaiting
      @log "warn", "Current activity poll has eaten itself"
    @_pollWaiting = true
    promise = @_harmony.getCurrentActivity()
    promise.catch (error) =>
      @log "error", "Failed to poll current activity (#{error})"
      @_pollWaiting = false
      deferred.reject()
    promise.then (activity) =>
      @log "verbose", "Current activity is #{activity}"
      @processData currentActivity: activity
      @_pollWaiting = false
      deferred.resolve()
    promise.done()
    deferred.promise

  turnOff: ->
    @_harmony.turnOff() # Returns promise

  startActivity: (id) ->
    @_harmony.startActivity(id) # Returns promise

  processData: (data) ->
    isOff = data['currentActivity'] == @powerOffActivityId
    @getAspect('mediaSource').setData
      state: if isOff then null else data["currentActivity"]
    @getAspect('powerOnOff').setData state: !isOff

  _processXMPPMessage: (message) ->
    child = message.children?[0]
    if child? and child.attrs?.type == "harmony.engine?startActivityFinished"
      details = child.children?[0] or ""
      details = _.object(details.split(':').map((d) -> d.split('=')))
      if details.activityId?
        activity = details.activityId
        @log "verbose", "XMPP indicates current activity is #{activity}"
        @processData currentActivity: activity
