
Backbone = require('backbone')
Controls = require('./Controls.coffee')
AppView = require('./AppView.coffee')

module.exports = class App extends Backbone.Model
  constructor: ->
    @log "Jarvis web client here"
    Backbone.$ = window.$
    @controls = new Controls()
    @view = new AppView(el: $('body'))
    @view.render()

  log: (one, two) ->
    # XXX Implement levels
    if two?
      console.log two
    else
      console.log one