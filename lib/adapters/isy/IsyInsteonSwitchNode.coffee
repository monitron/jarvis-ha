
IsyNode = require('./IsyNode')

module.exports = class IsyInsteonSwitchNode extends IsyNode
  key: 'insteonSwitch'
  types: [[2, 42], [2, 55]]

  aspects:
    powerOnOff:
      commands:
        set: (node, value) ->
          node.adapter.executeCommand node.id, (if value then 'DON' else 'DOF')

  processData: (data) ->
    if data.ST? then @getAspect('powerOnOff').setData state: (data.ST != '0')
