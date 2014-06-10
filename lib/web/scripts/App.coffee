
Backbone = require('backbone')
[Control, Controls] = require('../../Control.coffee')
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

  log: (one, two) ->
    # XXX Implement levels
    if two?
      console.log two
    else
      console.log one