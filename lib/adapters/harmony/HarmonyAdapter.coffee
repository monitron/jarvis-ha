
Adapter = require('../../Adapter')
HarmonyHubNode = require('./HarmonyHubNode')

module.exports = class HarmonyAdapter extends Adapter
  name: "Harmony"
  defaults:
    devices: {}
    keepaliveInterval: 45

  start: ->
    for id, host of @get('devices')
      @children.add new HarmonyHubNode(
        {id: id, host: host, keepaliveInterval: @get('keepaliveInterval')},
        adapter: this)
