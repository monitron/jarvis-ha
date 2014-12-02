
InsteonNode = require('./InsteonNode')

module.exports = class InsteonSwitchNode extends InsteonNode
  aspects:
    powerOnOff:
      commands:
        set: (node, value) ->
          node.adapter.toggleLight(node.id, value).then ->
            node.getAspect('powerOnOff').setData state: value
