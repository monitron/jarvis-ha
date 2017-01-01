
_ = require('underscore')
winston = require('winston')
fs = require('fs')
yaml = require('js-yaml')
Q = require('q')

[Control, Controls] = require('./Control')
controls = require('./controls')
WebServer = require('./web')
Slack = require('./Slack')
Persistence = require('./Persistence')
[AdapterNode, AdapterNodes] = require('./AdapterNode')
[Capability, Capabilities] = require('./Capability')
capabilities = require('./capabilities')
[Scene, Scenes] = require('./Scene')
[Event, Events] = require('./Event')

module.exports = class Server
  constructor: ->
    winston.clear()
    winston.add winston.transports.Console, level: 'verbose'
    winston.add winston.transports.File,
      filename: 'jarvis.log'
      level: 'verbose'
      json: false
    winston.cli()
    @log 'info', 'Jarvis Home Automation server'
    @config = @readConfig()
    if @config.debug then require('longjohn')
    @persistence = new Persistence()
    @events = new Events()
    # Gather adapters
    @adapters = new AdapterNodes()
    @adapters.on 'deepEvent', (path, ev, args) =>
      @log 'debug', "Saw adapter event: #{path.join('/')} emitted #{ev}"
    for config in @config.adapters
      adapterClass = require("./adapters/#{config.id}")
      @adapters.add new adapterClass(config, {server: this})
    # Start adapters
    @adapters.each (adapter) =>
      if adapter.isEnabled()
        @log 'info', "Starting #{adapter.name} adapter"
        adapter.start()
      else
        @log 'info', "Not starting disabled #{adapter.name} adapter"
    # Now let's controls
    @controls = new Controls()
    for controlConfig in (@config.controls or [])
      @controls.add new controls[controlConfig.type](controlConfig, {server: this})
    # Build capabilities
    @capabilities = new Capabilities()
    for capConfig in (@config.capabilities or [])
      @capabilities.add new capabilities[capConfig.id](capConfig, {server: this})
    # Start capabilities
    @capabilities.each (cap) =>
      if cap.isEnabled()
        @log 'info', "Starting #{cap.name} capability"
        cap.start()
      else
        @log 'info', "Not starting disabled #{cap.name} capability"
    # Build scenes
    @scenes = new Scenes(@config.scenes or [], server: this)
    # Start a web server
    @web = new WebServer(this, @config.webServer)
    # Start Slack integration if applicable
    if @config.slack?
      @slack = new Slack(this, @config.slack)

  log: (level, message) ->
    winston.log level, "#{message}"

  readConfig: ->
    text = fs.readFileSync(__dirname + '/../configuration.yml', 'utf8')
    yaml.safeLoad(text)

  naturalCommand: (command) ->
    # XXX contractions must go
    command = command
      .toLowerCase()                   # all matching is done in lcase
      .replace(/%/g, ' percent ')      # % -> percent
      .replace(/[\u2018\u2019]/g, "'") # dumben apostrophes
      .replace(/[^a-z0-9\']+/g, ' ')   # keep only alpha/num/'/space
      .replace(/\ +/g, ' ')            # multiple spaces -> one space
      .trim()                          # remove leading/trailing spaces
    @log 'debug', "Command as heard: #{command}"
    candidates = []
    @capabilities.each (cap) =>
      for commandId, params of cap.naturalCommandCandidates(command)
        candidates.push
          capability: cap.id
          command: commandId
          params: params
    if candidates.length == 1
      # Returns a promise of a response
      cmd = candidates[0]
      @capabilities.get(cmd.capability).
        executeNaturalCommand cmd.command, cmd.params
    else if candidates.length == 0
      Q.fcall => "Sorry, I couldn't understand."
    else
      Q.fcall => "Sorry, multiple commands matched your request."