
IsyNode = require('./IsyNode')

module.exports = class IsyInsteonDimmerNode extends IsyNode
  key: 'insteonDimmer'
  types: [[1, 14], [1, 32]]

  aspects:
    powerOnOff:
      commands:
        set: (node, value) ->
          if value
            node.adapter.executeCommand node.id, 'DON', 255
          else
            node.adapter.executeCommand node.id, 'DOF'
    brightness:
      commands:
        set: (node, value) ->
          node.adapter.executeCommand node.id, 'DON', node.percentageToByte(value)

  processData: (data) ->
    if data.ST?
      brightness = parseInt(data.ST)
      @getAspect('powerOnOff').setData state: (brightness != 0)
      @getAspect('brightness').setData state: @byteToPercentage(brightness)
