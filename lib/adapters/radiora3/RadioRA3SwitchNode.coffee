[AdapterNode] = require('../../AdapterNode')

module.exports = class RadioRA3SwitchNode extends AdapterNode
  type: 'Switched'

  aspects:
    powerOnOff:
      commands:
        set: (node, value) ->
          node.setOnOff(value)

  setOnOff: (value) ->
    numericValue = if value then 100 else 0
    @adapter.doZoneCommand @id,
      CommandType: 'GoToLevel'
      Parameter: [{Type: "Level", Value: numericValue}]

  processData: (data) ->
    @getAspect('powerOnOff').setData state: data.SwitchedLevel == "On"
