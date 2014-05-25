
InsteonNode = require('./InsteonNode')

module.exports = class InsteonDimmerNode extends InsteonNode
  aspects:
    toggle:
      commands:
        set: (node, value) -> node.adapter.toggleLight(node.id, value)
