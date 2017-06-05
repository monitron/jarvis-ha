
express = require('express')
http = require('http')
winston = require('winston')
socketio = require('socket.io')
bodyParser = require('body-parser')

module.exports = class WebServer
  constructor: (@_server, @_config) ->
    app = express()

    httpServer = http.Server(app)
    io = socketio(httpServer)

    app.use bodyParser.urlencoded()
    app.use bodyParser.json()

    app.get /^\/api\/paths\/(.*)$/, (req, res) =>
      path = @normalizePath(unescape(req.params[0]))
      res.json @_server.controls.findMembersOfPath(path)

    app.get "/api/stations/:stationId", (req, res) =>
      res.json @_server.config.stations?[req.params.stationId] or {}

    app.get "/api/controls", (req, res) =>
      res.json @_server.controls

    app.get "/api/capabilities", (req, res) =>
      res.json @_server.capabilities

    app.post "/api/capabilities/:capabilityId/commands/:commandId", (req, res) =>
      capability = @_server.capabilities.get(req.params.capabilityId)
      capability.executeCommand req.params.commandId, req.body
        .then -> res.json success: true
        .catch (why) =>
          @log 'warn', "Command failed on capability #{req.params.capabilityId}: #{JSON.stringify(why)}"
          res.json 500, {success: false, message: why}
        .done()

    app.get "/api/scenes", (req, res) =>
      res.json @_server.scenes

    app.get "/api/events", (req, res) =>
      res.json @_server.events.ongoing()

    app.post "/api/scenes/:sceneId/activate", (req, res) =>
      scene = @_server.scenes.get(req.params.sceneId)
      scene.activate()
        .then -> res.json success: true
        .catch (why) =>
          @log 'warn', "Failed to activate scene #{req.params.sceneId}: #{JSON.stringify(why)}"
          res.json 500, {success: false, message: why}
        .done()

    app.get "/api/controls/:controlId", (req, res) =>
      control = @_server.controls.get(req.params.controlId)
      res.json control

    app.post "/api/controls/:controlId/commands/:commandId", (req, res) =>
      control = @_server.controls.get(req.params.controlId)
      control.executeCommand req.params.commandId, req.body
        .then -> res.json success: true
        .catch (why) =>
          @log 'warn', "Command failed on control #{req.params.controlId}: #{JSON.stringify(why)}"
          res.json 500, {success: false, message: why}
        .done()

    app.post "/integrations/apiai", (req, res) =>
      @_server.naturalCommand req.body.result.resolvedQuery
        .then (resp) -> res.json speech: resp, displayText: resp
        .fail (resp) -> res.json speech: resp, displayText: resp

    app.post "/api/natural/:command", (req, res) =>
      @_server.naturalCommand req.params.command
        .then (resp) -> res.json success: true,  response: resp
        .fail (resp) -> res.json success: false, response: resp

    app.use express.static(__dirname + '/public')

    io.on 'connection', (socket) =>
      @log 'debug', 'A client socket connected'
      notifyControlChange = (model) =>
        @log 'verbose', "Notifying client of change to control #{model.id}"
        socket.emit 'control:change', model.toJSON()
      @_server.controls.on 'change', notifyControlChange, socket
      notifyCapabilityChange = (model) =>
        @log 'verbose', "Notifying client of change to capability #{model.id}"
        socket.emit 'capability:change', model.toJSON()
      @_server.capabilities.on 'change', notifyCapabilityChange, socket
      notifyOngoingEventsChange = (model) =>
        @log 'verbose', "Notifying client of change to ongoing events"
        socket.emit 'events:change',
          @_server.events.ongoing().map((e) -> e.toJSON())
      @_server.events.on 'add remove change', notifyOngoingEventsChange, socket

      socket.on 'disconnect', =>
        @log 'debug', 'Client socket disconnected; unregistering notifications'
        @_server.controls.off 'change', notifyControlChange, socket
        @_server.capabilities.off 'change', notifyCapabilityChange, socket

    httpServer.listen @_config.port, =>
      @log 'info', "Listening on port #{httpServer.address().port}"

  normalizePath: ->
    if _.isString(path) then path.split("/") else path

  log: (level, message) ->
    winston.log level, "[WebServer] #{message}"
