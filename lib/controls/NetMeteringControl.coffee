[Control] = require('../Control')

module.exports = class NetMeteringControl extends Control
  _getState: ->
    usage = @getConnectionTarget('usageEnergySensor')
    generation = @getConnectionTarget('generationEnergySensor')
    used: usage?.getAspect('energySensor').getDatum('value')
    generated: generation?.getAspect('energySensor').getDatum('value')