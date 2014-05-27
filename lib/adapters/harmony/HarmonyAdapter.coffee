
Adapter = require('../../Adapter')
harmony = require('harmonyjs')

module.exports = class HarmonyAdapter extends Adapter
  name: "Harmony"

  constructor: (config) ->
    super config
    @setValid false

  start: ->
    promise = harmony(@config.email, @config.password, @config.hubHost)
    promise.done(
      (client) =>
        @log "debug", "Connected to Harmony"
        @_harmony = client
        @setValid true
    , (error) =>
        @log "error", "Failed to connect to Harmony (#{error})"
    )