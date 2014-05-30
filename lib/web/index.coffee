
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

    app.get "/api/controls/:controlId/commands/:commandId", (req, res) =>
      control = @_server.getControl(req.params.controlId)
      control.executeCommand req.params.commandId
      res.send "I guess we did something XXX LOLZ"

    server = app.listen @_config.port, =>
      winston.info "Web server listening on port #{server.address().port}"