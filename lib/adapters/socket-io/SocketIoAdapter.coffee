_ = require('underscore')

Adapter = require('../../Adapter')
SocketIoNode = require('./SocketIoNode')
io = require('socket.io-client')

# Connects to a socket.io server which sends messages when values change and
# takes messages to execute commands.
# Configuration would look something like this:
#
# adapters:
#   - id: socket-io
#     servers:
#       device1: http://1.2.3.4:5555/
#     devices:
#       a-door:
#         openCloseSensor:
#           data:
#             state:
#               server: device1
#               slot: a-door-open
#         lock:
#           commands:
#             unlock:
#               server: device1
#               slot: a-door-unlock

module.exports = class SocketIoAdapter extends Adapter
  name: 'Socket.IO'
  defaults:
    servers: {}
    devices: {}

  start: ->
    @_clients = {}
    _.each @get('servers'), (url, connKey) =>
      @log 'debug', "connecting to #{connKey} at #{url}"
      client = io(url)
      @_clients[connKey] = client
      client.on 'connect', => @log 'verbose', "Connected to #{connKey}"
      client.on 'connect_error', (e) =>
        @log 'warn', "Failed to connect to #{connKey}: #{e}"
      client.on 'connect_timeout', =>
        @log 'warn', "Timed out trying to connect to #{connKey}"
      client.on 'error', (e) =>
        @log 'warn', "Error communicating with #{connKey}: #{e}"
      client.on 'disconnect', (reason) =>
        @log 'warn', "Disconnected from #{connKey}: #{reason}"
      client.on 'reconnect_attempt', (num) =>
        @log 'debug', "Attempting to reconnect to #{connKey} (try #{num})"
      client.on 'reconnect_failed', =>
        @log 'error', "Giving up on reconnecting to #{connKey}!"
    console.log "got clients", @_clients
    for id, config of @get('devices')
      config = {id: id, aspects: config}
      @children.add new SocketIoNode(config, adapter: this)

  client: (server) ->
    console.log "looking for", server
    @_clients[server]