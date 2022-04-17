[AdapterNode] = require('../../AdapterNode')

module.exports = class RadioRA3DimmerNode extends AdapterNode
  type: 'Dimmed'

  aspects:
    powerOnOff:
      commands:
        set: (node, value) ->
          node.setBrightness(if value then 100 else 0)
    brightness:
      commands:
        set: (node, value) ->
          node.setBrightness value

  setBrightness: (value) ->
    @adapter.doZoneCommand @id,
      CommandType: 'GoToDimmedLevel'
      DimmedLevelParameters:
        Level: value

  processData: (data) ->
    @log 'verbose', data.Level
    @log 'verbose', 'before: ' + JSON.stringify(@toJSON())
    @getAspect('brightness').setData state: data.Level
    @getAspect('powerOnOff').setData state: (data.Level != 0)
    @log 'verbose', 'after: ' + JSON.stringify(@toJSON())
