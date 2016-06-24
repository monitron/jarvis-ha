
Backbone = require('backbone')

module.exports = class OccupancySensorBodyView extends Backbone.View
  render: ->
    state = @model.get('state')
    context =
      isKnown: state.occupied?
      isOccupied: state.occupied
    @$el.html Templates['controls/occupancySensor'](context)
    this