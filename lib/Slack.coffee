winston = require('winston')
_ = require('underscore')
RtmClient = require('@slack/client').RtmClient
WebClient = require('@slack/client').WebClient
CLIENT_EVENTS = require('@slack/client').CLIENT_EVENTS
RTM_EVENTS = require('@slack/client').RTM_EVENTS

# Slack intergration

module.exports = class Slack
  # botToken is mandatory.
  # channel is very recommended (don't include the #)
  defaultConfig:
    eventImportance: ['medium', 'high']
    subscriptions: []

  emoji:
    resolved: ':white_check_mark:'
    importance:
      routine: ':white_circle:'
      low: ':information_source:'
      medium: ':warning:'
      high: ':negative_squared_cross_mark:'

  constructor: (@server, config) ->
    @config = _.defaults(config, @defaultConfig)
    @rtm = new RtmClient @config.botToken,
      dataStore: false
      useRtmConnect: true
    @web = new WebClient(@config.botToken)

    @rtm.on CLIENT_EVENTS.RTM.AUTHENTICATED, (data) =>
      @_myId = data.self.id
      @log 'debug', "Logged in to #{data.team.name} as #{data.self.name}"
      @web.users.list().then (response) => @_users = response.members
      @updateIMs()

    @rtm.on CLIENT_EVENTS.RTM.UNABLE_TO_RTM_START, =>
      @log 'warn', 'Failed trying to log in to Slack.'

    @rtm.on CLIENT_EVENTS.RTM.DISCONNECT, =>
      @log 'error', 'Disconnected permanently from Slack.'

    @rtm.on CLIENT_EVENTS.RTM.RTM_CONNECTION_OPENED, =>
      @log 'info', 'Connected to Slack.'

    @rtm.on RTM_EVENTS.MESSAGE, (msg) => @onMessage(msg)

    @server.events.on 'add', (event) => @notifyNewEvent(event)
    @server.events.on 'change', (event) => @notifyChangedEvent(event)

    @rtm.start()

  channelId: ->
    @config.channel? && ('#' + @config.channel)

  notifyNewEvent: (event) ->
    channel = @channelId()
    message = @emoji.importance[event.get('importance')] + ' '
    if event.isOngoing() then message += '*Ongoing:* '
    message += event.get('title')
    if channel? and _.contains(@config.eventImportance, event.get('importance'))
      @sendMessage @channelId(), message
    for sub in @subscriptionsMatchingEvent(event)
      @sendIM sub.username, message


  notifyChangedEvent: (event) ->
    channel = @channelId()
    if !event.isOngoing()
      message = @emoji.resolved + ' *Resolved:* ' + event.get('title')
      if channel? and _.contains(@config.eventImportance, event.get('importance'))
        @sendMessage @channelId(), message
      for sub in @subscriptionsMatchingEvent(event)
        @sendIM sub.username, message

  onMessage: (msg) ->
    @log 'verbose', "Message: #{JSON.stringify(msg)}"
    if msg.channel[0] == 'D' and msg.user != @_myId
      # This is a direct message. Try interpreting it as a NLP command
      @server.naturalCommand(msg.text or msg.attachments?[0]?.fallback)
        .then (reply) => @sendMessage msg.channel, reply
        .fail (reply) => @sendMessage msg.channel, reply

  subscriptionsMatchingEvent: (event) ->
    _.filter @config.subscriptions, (sub) =>
      sub.sourceType == event.get('sourceType') and
        (!sub.sourceId? or sub.sourceId == event.get('sourceId')) and
        (!sub.importance? or _.contains(sub.importance, event.get('importance')))

  sendIM: (username, message, options = {}) ->
    # Wow, this is needlessly complex. First find user ID
    id = _.findWhere(@_users, name: username)?.id
    if id?
      # Do we already have an IM session for this user?
      session = _.findWhere(@_ims, user: id)
      if session
        # Good to send the message
        @sendMessage session.id, message, options
      else
        # Start an IM session first
        @log 'verbose', "Opening an IM channel with user #{id}"
        @web.im.open(id).then (resp) =>
          @updateIMs() # For next time we need to send to this person
          @sendMessage resp.channel.id, message, options
    else
      @log 'warn', "Could not find user ID for username '#{username}'"

  sendMessage: (channel, message, options = {}) ->
    _.defaults options, {as_user: true}
    @web.chat.postMessage channel, message, options

  updateIMs: ->
    @web.im.list().then (response) => @_ims = response.ims

  log: (level, message) ->
    winston.log level, "[Slack] #{message}"
