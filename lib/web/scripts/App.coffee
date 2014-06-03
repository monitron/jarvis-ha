
Backbone = require('backbone')

module.exports = class App extends Backbone.Model
  constructor: ->
    @log "Jarvis web client here"

  log: (one, two) ->
    # XXX Implement levels
    if two?
      console.log two
    else
      console.log one