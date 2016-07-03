
Backbone = require('backbone')
[Control, Controls] = require('./Control.coffee')
Router = require('./Router.coffee')
AppView = require('./AppView.coffee')

module.exports = class App extends Backbone.Model
  initialize: ->
    @log "Jarvis web client here"
    Backbone.$ = window.$
    @router = new Router(app: this)
    @controls = new Controls()
    @currentPath = null
    $.when(@controls.fetch()).done =>
      @log "Startup tasks are finished"
      @view = new AppView(el: $('body'), model: this)
      @view.render()
      Backbone.history.start()
      @setupSocket()

  setupSocket: ->
    @socket = io()
    @socket.on 'connect', => @log 'Socket connected'
    @socket.on 'disconnect', => @log 'Socket disconnected!'
    @socket.on 'reconnect', => @log 'Socket reconnected'
    @socket.on 'reconnect_failed', => @log 'Socket gave up reconnecting!!'
    @socket.on 'control:change', (controlJSON) =>
      control = @controls.get(controlJSON.id)
      unless control?
        @log 'warn', "Received update about unknown control #{controlJSON.id}"
      control.set controlJSON

  log: (one, two) ->
    # XXX Implement levels
    if two?
      console.log two
    else
      console.log one
