
_ = require('underscore')
Adapter = require('../../Adapter')
harmony = require('harmonyhubjs-client')
HarmonyHubNode = require('./HarmonyHubNode')

# TODO: Listen to unsolicited XMPP events

module.exports = class HarmonyAdapter extends Adapter
  powerOffActivityId: '-1' # This activity signifies the system is off

  name: "Harmony"
  defaults:
    keepaliveInterval: 45

  initialize: ->
    super
    @setValid false

  start: ->
    promise = harmony(@get('email'), @get('password'), @get('hubHost'))
    promise.catch (error) =>
      @log "error", "Failed to connect to Harmony (#{error})"
    promise.then (client) =>
      @log "debug", "Connected to Harmony"
      @_harmony = client
      @discoverActivities()
      @_keepalive = setInterval((=> @pollCurrentActivity()),
        @get('keepaliveInterval') * 1000)
      #@_harmony._xmppClient.on 'stanza', (s) -> console.log(s)
    promise.done()

  discoverActivities: ->
    @log "debug", "Discovering activities..."
    promise = @_harmony.getActivities()
    @_apromise = promise
    promise.catch (error) =>
      @log "error", "Failed to discover activities (#{error})"
    promise.then (activities) =>
      activityMap = {}
      # Fun fact: activity IDs are strings and must stay that way
      (activityMap[activity.id] = activity.label) for activity in activities
      @log "debug", "Discovered #{_.size(activityMap)} activities"
      @children.add new HarmonyHubNode {id: 'hub'},
        adapter: this
        attributes:
          mediaSource: {choices: _.omit(activityMap, @powerOffActivityId)}
      @setValid true
      @pollCurrentActivity() # Get initial state
    promise.done()

  pollCurrentActivity: ->
    @log "verbose", "Polling current activity..."
    if @_pollWaiting
      @log "warn", "Current activity poll has eaten itself"
    @_pollWaiting = true
    promise = @_harmony.getCurrentActivity()
    promise.catch (error) =>
      @log "error", "Failed to poll current activity (#{error})"
      @_pollWaiting = false
    promise.then (activity) =>
      @log "verbose", "Current activity is #{activity}"
      @children.first().processData currentActivity: activity
      @_pollWaiting = false
    promise.done()

  turnOff: ->
    @_harmony.turnOff() # Returns promise

  startActivity: (id) ->
    @_harmony.startActivity(id) # Returns promise