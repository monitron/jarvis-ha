
winston = require('winston')

module.exports = class Server
  constructor: ->
    winston.clear()
    winston.add winston.transports.Console, level: 'debug'
    winston.cli()
    winston.info "Jarvis Home Automation server"
    @config = @dummyConfig()
    # Gather adapters
    @adapters = {}
    for id, config of @config.adapters
      adapterClass = require("./adapters/#{id}")
      @adapters[id] = new adapterClass(config)
    # Start adapters
    for id, adapter of @adapters
      winston.info "Starting #{adapter.name} adapter"
      adapter.start()

  dummyConfig: ->
    adapters:
      nest:
      insteon:
        base:
          "gateway-type": "hub"
          "gateway-host": "192.168.1.17"
        devices:
          "basement-entry-light":
            type: "dimmer"
            address: "2bc0d3"
