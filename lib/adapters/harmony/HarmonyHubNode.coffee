
[AdapterNode] = require('../../AdapterNode')

module.exports = class HarmonyHubNode extends AdapterNode
  aspects:
    mediaSource:
      commands:
        set: (node, value) ->
          node.adapter.startActivity(value).then ->
            node.getAspect('powerOnOff').setData  state: true
            node.getAspect('mediaSource').setData state: value
      events:
        changed: (prev, cur) -> prev.state != cur.state
    powerOnOff:
      commands:
        set: (node, value) ->
          return if value # Turning on isn't meaningful
          node.adapter.turnOff().then ->
            node.getAspect('powerOnOff').setData  state: false
            node.getAspect('mediaSource').setData state: null
      events:
        changed: (prev, cur) -> prev.state != cur.state

  processData: (data) ->
    isOff = data['currentActivity'] == @adapter.powerOffActivityId
    @getAspect('mediaSource').setData
      state: if isOff then null else data["currentActivity"]
    @getAspect('powerOnOff').setData state: !isOff