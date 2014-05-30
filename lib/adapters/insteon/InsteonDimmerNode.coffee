
InsteonNode = require('./InsteonNode')

module.exports = class InsteonDimmerNode extends InsteonNode
  aspects:
    powerOnOff:
      commands:
        set: (node, value) -> node.adapter.toggleLight(node.id, value)
