
InsteonNode = require('./InsteonNode')

module.exports = class InsteonFanNode extends InsteonNode
  interfaceType: 'fanlinc'

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
    discreteSpeed:
      commands:
        set: (node, value) ->
          node.adapter.sendCommand(node.id, 'fan', speed: value).then ->
            node.getAspect('discreteSpeed').setData state: value
      attributes:
        choices: [
          {id: 'off',  shortName: 'Off',  longName: 'Off'}
          {id: 'low',  shortName: 'Low',  longName: 'Low'}
          {id: 'med',  shortName: 'Med',  longName: 'Medium'}
          {id: 'high', shortName: 'High', longName: 'High'}]

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
    if data.speed?
      @getAspect('discreteSpeed').setData state: data.speed
