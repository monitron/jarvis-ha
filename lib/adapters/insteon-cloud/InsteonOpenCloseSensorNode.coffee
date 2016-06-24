
InsteonNode = require('./InsteonNode')

module.exports = class InsteonOpenCloseSensorNode extends InsteonNode
  interfaceType: 'openClose'
  statusQueryable: false

  aspects:
    openCloseSensor: {}

  processData: (data) ->
    if data.open?
      @getAspect('openCloseSensor').setData state: data.open