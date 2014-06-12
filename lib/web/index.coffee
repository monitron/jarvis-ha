
express = require('express')
http = require('http')
winston = require('winston')
socketio = require('socket.io')

module.exports = class WebServer
  constructor: (@_server, @_config) ->
    app = express()
    httpServer = http.Server(app)
    io = socketio(httpServer)

    app.get /^\/api\/paths\/(.*)$/, (req, res) =>
      path = @normalizePath(unescape(req.params[0]))
      res.json @_server.controls.findMembersOfPath(path)

    app.get "/api/controls", (req, res) =>
      res.json @_server.controls

    app.get "/api/controls/:controlId", (req, res) =>
      control = @_server.controls.get(req.params.controlId)
      res.json control

    app.post "/api/controls/:controlId/commands/:commandId", (req, res) =>
      control = @_server.controls.get(req.params.controlId)
      control.executeCommand req.params.commandId, req.query
        .then -> res.json success: true
        .catch (why) -> res.json 500, {success: false, message: why}
        .done()

    app.use express.static(__dirname + '/public')

    io.on 'connection', (socket) ->
      winston.debug "A client socket connected"

    httpServer.listen @_config.port, =>
      winston.info "Web server listening on port #{httpServer.address().port}"

  normalizePath: ->
    if _.isString(path) then path.split("/") else path
