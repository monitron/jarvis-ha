
InsteonNode = require('./InsteonNode')

module.exports = class InsteonDimmerNode extends InsteonNode
  interfaceType: 'light'

  aspects:
    powerOnOff:
      commands:
        set: (node, value) ->
          node.adapter.toggleLight(node.id, value).then ->
            node.getAspect('powerOnOff').setData state: value
            node.getAspect('brightness').setData state: if value then 100 else 0
    brightness:
      commands:
        set: (node, value) ->
          node.adapter.setLightLevel(node.id, value).then ->
            node.getAspect('powerOnOff').setData state: (value != 0)
            node.getAspect('brightness').setData state: value

  processData: (data) ->
    if data.power?
      @getAspect('powerOnOff').setData state: data.power
      # Brightness state can be inferred from power (if it's off)
      if !data.brightness? and !data.power
        @getAspect('brightness').setData state: 0
    if data.brightness?
      @getAspect('brightness').setData state: data.brightness
      # Power state can be inferred from brightness
      if !data.power?
        @getAspect('powerOnOff').setData state: data.brightness != 0
