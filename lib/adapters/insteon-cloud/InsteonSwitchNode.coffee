
InsteonNode = require('./InsteonNode')

module.exports = class InsteonSwitchNode extends InsteonNode
  interfaceType: 'light'

  aspects:
    powerOnOff:
      commands:
        set: (node, value) ->
          node.adapter.toggleLight(node.id, value).then ->
            node.getAspect('powerOnOff').setData state: value

  processData: (data) ->
    if data.power?
      @getAspect('powerOnOff').setData state: data.power