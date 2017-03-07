
IsyNode = require('./IsyNode')

module.exports = class IsyInsteonSwitchNode extends IsyNode
  key: 'insteonSwitch'
  types: [[2, 42], [2, 55]]

  aspects:
    powerOnOff:
      commands:
        set: (node, value) ->
          command = if value then 'DON' else 'DOF'
          operative = value != node.getAspect('powerOnOff').getDatum('state')
          node.adapter.executeCommand node.id, command, [], operative

  processData: (data) ->
    if data.ST? then @getAspect('powerOnOff').setData state: (data.ST != '0')
