
winston = require('winston')

module.exports = class Server
  constructor: ->
    winston.info "Jarvis Home Automation server"
    @config = @dummyConfig()
    # Gather adapters
    @adapters = {}
    for id, config of @config.adapters
      adapterClass = require("./adapters/#{id}")
      @adapters[id] = new adapterClass(config)
    # Start adapters
    adapter.start() for id, adapter of @adapters

  dummyConfig: ->
    adapters:
      insteon:
        base:
          "gateway-type": "hub"
          "gateway-host": "192.168.1.17"
        devices:
          "basement-entry-light":
            type: "dimmer"
            address: "2bc0d3"
