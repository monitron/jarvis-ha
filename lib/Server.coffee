
_ = require('underscore')
winston = require('winston')

module.exports = class Server
  constructor: ->
    winston.clear()
    winston.add winston.transports.Console, level: 'verbose'
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
    # Now let's controls
    @controls = for controlConfig in @config.controls
      controlClass = require("./controls/#{controlConfig.type}")
      new controlClass(this, controlConfig)

  getAdapterNode: (path) ->
    path = @normalizePath(path)
    node = @adapters[path.shift()] # First element is adapter name
    for element in path
      return undefined unless node?
      node = node.getChild(element)
    node

  getMemberControls: (path) ->
    path = @normalizePath(path)
    pairs = for control in @controls
      control: control
      membership: control.getMembership(path)
    _.select(pairs, (p) -> p.membership?)

  normalizePath: (path) ->
    if _.isString(path) then path.split("/") else path

  dummyConfig: ->
    adapters:
      nest:
        login: "somebody@somewhere.com"
        password: "correct horse battery staple"
      insteon:
        gatewayType: "hub"
        gatewayHost: "192.168.1.17"
        deviceIds: ["2bc0d3", "2bb7c6"]
      harmony:
        email: "somebody@somewhere.com"
        password: "correct horse battery staple"
        hubHost: "192.168.1.5"
    controls: [
      {
        name: "Basement Entry Light"
        type: "dimmer"
        memberships: [
          {path: "category/Lighting"}
          {path: "location/Main Floor/Living Room"}
          {path: "location/Basement/Main Room"}]
        connections:
          powerOnOff: "insteon/2bc0d3"
          dimmer: "insteon/2bc0d3"
      }
    ]
