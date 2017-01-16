
module.exports = class UserScript
  constructor: (@server) ->

  log: (level, message) ->
    @server.log level, "[#{@name} user script] #{message}"
