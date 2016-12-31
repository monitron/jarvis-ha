winston = require('winston')
_ = require('underscore')
RtmClient = require('@slack/client').RtmClient
CLIENT_EVENTS = require('@slack/client').CLIENT_EVENTS
RTM_EVENTS = require('@slack/client').RTM_EVENTS

# Slack intergration

module.exports = class Slack
  # botToken and channel are mandatory
  defaultConfig:
    eventImportance: ['medium', 'high']

  emoji:
    resolved: ':white_check_mark:'
    importance:
      low: ':information_source:'
      medium: ':warning:'
      high: ':negative_squared_cross_mark:'

  constructor: (@server, config) ->
    @config = _.defaults(config, @defaultConfig)
    @rtm = new RtmClient(@config.botToken)

    @rtm.on CLIENT_EVENTS.RTM.AUTHENTICATED, (data) =>
      @log 'debug', "Logged in to #{data.team.name} as #{data.self.name}"

    @rtm.on CLIENT_EVENTS.RTM.UNABLE_TO_RTM_START, =>
      @log 'warn', 'Failed trying to log in to Slack.'

    @rtm.on CLIENT_EVENTS.RTM.DISCONNECT, =>
      @log 'error', 'Disconnected permanently from Slack.'

    @rtm.on CLIENT_EVENTS.RTM.RTM_CONNECTION_OPENED, =>
      @log 'info', 'Connected to Slack.'

    @rtm.on RTM_EVENTS.MESSAGE, (msg) =>
      @log 'verbose', "Message: #{JSON.stringify(msg)}"

    @server.events.on 'add', (event) => @notifyNewEvent(event)
    @server.events.on 'change', (event) => @notifyChangedEvent(event)

    @rtm.start()

  channelId: ->
    @rtm.dataStore.getChannelByName(@config.channel)?.id

  notifyNewEvent: (event) ->
    if _.contains(@config.eventImportance, event.get('importance'))
      message = @emoji.importance[event.get('importance')] + ' '
      if event.isOngoing() then message += '*Ongoing:* '
      message += event.get('title')
      @rtm.sendMessage message, @channelId()

  notifyChangedEvent: (event) ->
    if _.contains(@config.eventImportance, event.get('importance')) and !event.isOngoing()
      message = @emoji.resolved + ' *Resolved:* ' + event.get('title')
      @rtm.sendMessage message, @channelId()

  log: (level, message) ->
    winston.log level, "[Slack] #{message}"