
[AdapterNode] = require('../../AdapterNode')

# This is a sub-node of OccupantsNode
module.exports = class OccupantsIndividualNode extends AdapterNode
  aspects:
    occupantSensor: {}

  processData: (data) ->
    @getAspect('occupantSensor').setData
      state: data.state
      confident: data.confident
      time: data.time?.toDate()