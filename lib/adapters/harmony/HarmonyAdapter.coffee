
Adapter = require('../../Adapter')
harmony = require('harmonyjs')

module.exports = class HarmonyAdapter extends Adapter
  name: "Harmony"

  initialize: ->
    super
    @setValid false

  start: ->
    promise = harmony(@get('email'), @get('password'), @get('hubHost'))
    promise.done(
      (client) =>
        @log "debug", "Connected to Harmony"
        @_harmony = client
        @setValid true
    , (error) =>
        @log "error", "Failed to connect to Harmony (#{error})"
    )