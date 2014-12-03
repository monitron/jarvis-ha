
_ = require('underscore')
winston = require('winston')
fs = require('fs')
yaml = require('js-yaml')

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
    @config = @readConfig()
    # Gather adapters
    @adapters = new AdapterNodes()
    @adapters.on 'deepEvent', (path, ev, args) =>
      @log 'debug', "Saw adapter event: #{path.join('/')} emitted #{ev}"
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

  log: (level, message) ->
    winston.log level, "[#{@name} adapter] #{message}"

  readConfig: ->
    text = fs.readFileSync(__dirname + '/../configuration.yml', 'utf8')
    yaml.safeLoad(text)
