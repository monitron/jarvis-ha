HueNode = require('./HueNode')
_ = require('underscore')

module.exports = class HueGroupNode extends HueNode
  setState: (state) ->
    @adapter.setGroupState @id, state

  # The expected data is the state of all lights, from which the group state is
  # synthesized.
  processData: (data) ->
    @_processData @_synthesizeGroupState(data)

  _synthesizeGroupState: (lightsData) ->
    lightStates = @get('lights').map((id) => _.findWhere(lightsData, {id: id})?.state)
    # all lights must exist for a meaningful answer
    return {} unless _.every(lightStates, (state) => state?)
    groupState = {}
    # This list will need to be updated when we care about other attributes.
    # The value comparison method (uniq) will need to change if any complex
    # values (e.g. xy, which is an array) are added.
    for attr in ['on', 'bri', 'colormode', 'ct', 'hue', 'sat']
      vals = _.map(lightStates, attr)
      if _.uniq(vals).length == 1 then groupState[attr] = vals[0]
    groupState
