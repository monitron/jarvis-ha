
express = require('express')
app = express()
winston = require('winston')

module.exports = class WebServer
  constructor: (@_server, @_config) ->
    app.get /^\/api\/paths\/(.*)$/, (req, res) =>
      path = @_server.normalizePath(unescape(req.params[0]))
      res.send JSON.stringify
        path: path
        memberControls: @_server.getMemberControls(path)

    app.get "/api/controls", (req, res) =>
      res.json @_server.controls

    app.get "/api/controls/:controlId", (req, res) =>
      control = @_server.getControl(req.params.controlId)
      res.json control

    app.get "/api/controls/:controlId/commands/:commandId", (req, res) =>
      control = @_server.getControl(req.params.controlId)
      control.executeCommand req.params.commandId, req.query
        .then -> res.json success: true
        .catch (why) -> res.json 500, {success: false, message: why}
        .done()

    app.use express.static(__dirname + '/public')

    server = app.listen @_config.port, =>
      winston.info "Web server listening on port #{server.address().port}"