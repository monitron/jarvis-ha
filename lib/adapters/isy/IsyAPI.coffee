_ = require('underscore')
Q = require('q')
Backbone = require('backbone')
xml2js = require('xml2js')
request = require('request')
winston = require('winston')
WebSocketClient = require('websocket').client

module.exports = class IsyAPI extends Backbone.Model
  defaults:
    commandTimeout: 10000

  initialize: ->
    @_pendingCommands = {}

  connect: ->
    @_subscribe()

  getNodes: ->
    deferred = Q.defer()
    @_request('nodes')
      .then (data) =>
        nodes = for node in data.nodes.node
          address: node.address[0]
          name:    node.name[0]
          type:    node.type[0].split('.').map((x) -> parseInt(x))
          properties: _.object(for prop in node.property
            [prop['$'].id, prop['$'].value])
        deferred.resolve nodes
      .fail (err) => deferred.reject err
      .done()
    deferred.promise

  executeCommand: (node, command, args = [], expectResponse = true) ->
    @log 'verbose', "Command for #{node}: #{command} [#{args.join(', ')}] - " +
      (if expectResponse then "will await response" else "set and forget")
    deferred = Q.defer()
    req = @_request(['nodes', node, 'cmd', command].concat(args).join('/'))
      .fail (err) => deferred.reject err

    if expectResponse
      # If there already was a command pending for this node, mark it failed
      # (is this wise?)
      if @_pendingCommands[node]?
        @log 'debug', "Command superceded for #{node}"
        @_pendingCommands[node].reject 'superceded'
      # Add command as pending so it gets resolved when an update arrives
      @_pendingCommands[node] = deferred
      # Set a timeout so we notice if the update never happens
      cleanUpFailure = =>
        @log 'debug', "Command timed out for #{node}"
        delete @_pendingCommands[node]
        deferred.reject 'timeout'
      timeout = setTimeout cleanUpFailure, @get('commandTimeout')
      # The timeout must go away when the update arrives
      deferred.promise.then => clearTimeout(timeout)
    else # No response expected
      req.done -> deferred.resolve() # Resolve when command sending succeeds

    deferred.promise

  log: (level, message) ->
    winston.log level, "[IsyAPI] #{message}"

  _processSubscriptionMessage: (msg) ->
    xml2js.Parser().parseString msg.utf8Data, (err, data) =>
      if err?
        @log 'debug', "Unable to XML parse subscription message: #{msg}"
      else
        if data.Event? and data.Event.control[0][0] != '_' # Not an internal message
          node = data.Event.node[0]
          update =
            node: node
            property: data.Event.control[0]
            value: data.Event.action[0]
          @log 'verbose', "Dispatching property update #{JSON.stringify(update)}"
          @trigger 'property-update', update
          if @_pendingCommands[node]?
            @_pendingCommands[node].resolve()
            delete @_pendingCommands[node]

  _subscribe: ->
    # XXX Notice lack of heartbeats
    authDigest = new Buffer([@get('username'), @get('password')].join(':'))
      .toString('base64')
    socket = new WebSocketClient()
    socket.on 'connect', (connection) =>
      @log 'debug', 'Subscription successful'
      @trigger 'connected'
      @_connection = connection
      connection.on 'message', (msg) => @_processSubscriptionMessage(msg)
      connection.on 'close', (reason, desc) =>
        @log 'warn', "Subscription disconnected (#{reason}; #{desc})"
        @trigger 'disconnected'
        # XXX Reconnect?
    socket.on 'connectFailed', (error) =>
      @log 'warn', "Susbscription failed (#{error})" # XXX Try again?
      @trigger 'error'
      @trigger 'disconnected'
    socket.connect(
      "ws://#{@get('host')}/rest/subscribe",
      'ISYSUB',
      'com.universal-devices.websockets.isy',
      {Authorization: 'Basic ' + authDigest})

  _request: (resource) ->
    deferred = Q.defer()
    options =
      url: "http://#{@get('host')}/rest/#{resource}"
      auth:
        user: @get('username')
        pass: @get('password')
    @log 'verbose', "Making request: #{JSON.stringify(options)}"
    callback = (err, res, body) =>
      if err
        @log 'error', "Request of #{resource} failed: #{err}"
        deferred.reject err
      else
        xml2js.Parser().parseString body, (err, data) =>
          if err?
            @log 'warn', "Failed to parse XML: #{body}"
            deferred.reject err
          else
            deferred.resolve data
    request options, callback
    deferred.promise
