
IsyNode = require('./IsyNode')

module.exports = class IsyInsteonDimmerNode extends IsyNode
  key: 'insteonDimmer'
  types: [[1, 14], [1, 32]]

  aspects:
    powerOnOff:
      commands:
        set: (node, value) ->
          if value
            command = 'DON'
            args = [255]
            operative = node.getAspect('brightness').getDatum('state') != 255
          else
            command = 'DOF'
            args = []
            operative = node.getAspect('powerOnOff').getDatum('state') == true
          node.adapter.executeCommand node.id, command, args, operative
    brightness:
      commands:
        set: (node, value) ->
          operative = node.getAspect('brightness').getDatum('state') != value
          node.adapter.executeCommand node.id, 'DON',
            [node.percentageToByte(value)], operative

  processData: (data) ->
    if data.ST?
      brightness = parseInt(data.ST)
      @getAspect('powerOnOff').setData state: (brightness != 0)
      @getAspect('brightness').setData state: @byteToPercentage(brightness)
