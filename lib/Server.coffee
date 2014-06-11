
_ = require('underscore')
winston = require('winston')

[Control, Controls] = require('./Control')
controls = require('./controls')
WebServer = require('./web')
[AdapterNode, AdapterNodes] = require('./AdapterNode')

module.exports = class Server
  constructor: ->
    winston.clear()
    winston.add winston.transports.Console, level: 'verbose'
    winston.cli()
    @log 'info', 'Jarvis Home Automation server'
    @config = @dummyConfig()
    # Gather adapters
    @adapters = new AdapterNodes()
    for config in @config.adapters
      adapterClass = require("./adapters/#{config.id}")
      @adapters.add new adapterClass(config)
    # Start adapters
    @adapters.each (adapter) =>
      winston.info "Starting #{adapter.name} adapter"
      adapter.start()
    # Now let's controls
    @controls = new Controls()
    for controlConfig in @config.controls
      @controls.add new controls[controlConfig.type](controlConfig, {server: this})
    # Start a web server
    @web = new WebServer(this, @config.webServer)

  getAdapterNode: (path) ->
    path = _.clone(path)
    node = @adapters.get(path.shift()) # First path element is adapter id
    for element in path
      return undefined unless node?
      node = node.children.get(element)
    node

  log: (level, message) ->
    winston.log level, "[#{@name} adapter] #{message}"

  dummyConfig: ->
    adapters: [
      id: "nest"
      login: "some@guy.com"
      password: "correct horse battery staple"
    ,
      id: "insteon"
      gatewayType: "hub"
      gatewayHost: "192.168.1.17"
      deviceIds: ["2bc0d3", "2bb7c6", "26ce6c"]
    ,
      id: "harmony"
      email: "some@guy.com"
      password: "correct horse battery staple"
      hubHost: "192.168.1.5"
    ]
    controls: [
      {
        id: "basement-entry-light"
        name: "Basement Entry Light"
        type: "dimmer"
        memberships: [
          {path: ["category", "Lighting"]}
          {path: ["location", "Main Floor", "Living Room"]}
          {path: ["location", "Basement", "Main Room"]}]
        connections:
          powerOnOff: ["insteon", "2bc0d3"]
          brightness: ["insteon", "2bc0d3"]
      },
      {
        id: "thermostat"
        name: "Thermostat"
        type: "thermostat"
        memberships: [
          {path: ["category", "Climate"]}
          {path: ["location", "Main Floor", "Living Room"]}]
        connections:
          temperatureSensor: ["nest", "02AA01AC021401UM"]
          humiditySensor: ["nest", "02AA01AC021401UM"]
          temperatureSetPoint: ["nest", "02AA01AC021401UM"]
      }]
    webServer:
      port: 3000
