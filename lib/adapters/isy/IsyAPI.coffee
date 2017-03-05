_ = require('underscore')
Q = require('q')
Backbone = require('backbone')
xml2js = require('xml2js')
request = require('request')
winston = require('winston')
WebSocketClient = require('websocket').client

module.exports = class IsyAPI extends Backbone.Model
  connect: ->
    @_subscribe()

  getNodes: ->
    deferred = Q.defer()
    @_request('nodes')
      .fail (err) => deferred.reject err
      .done (data) =>
        nodes = for node in data.nodes.node
          address: node.address[0]
          name:    node.name[0]
          type:    node.type[0].split('.').map((x) -> parseInt(x))
          properties: _.object(for prop in node.property
            [prop['$'].id, prop['$'].value])
        deferred.resolve nodes
    deferred.promise

  executeCommand: (node, command, args = []) ->
    # Later: wait for update in stream
    deferred = Q.defer()
    @_request(['nodes', node, 'cmd', command].concat(args).join('/'))
      .fail (err) => deferred.reject err
      .done => deferred.resolve()
    deferred.promise

  log: (level, message) ->
    winston.log level, "[IsyAPI] #{message}"

  _processSubscriptionMessage: (msg) ->
    xml2js.Parser().parseString msg.utf8Data, (err, data) =>
      if err?
        @log 'debug', "Unable to XML parse subscription message: #{msg}"
      else
        if data.Event? and data.Event.control[0][0] != '_' # Not an internal message
          update =
            node: data.Event.node[0]
            property: data.Event.control[0]
            value: data.Event.action[0]
          @log 'verbose', "Dispatching property update #{JSON.stringify(update)}"
          @trigger 'property-update', update

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
    req = request options, callback
    deferred.promise
