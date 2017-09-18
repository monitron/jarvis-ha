[Control] = require('../Control')

module.exports = class OccupancySensorControl extends Control
  _getState: ->
    occupancy = @getConnectionTarget('occupancySensor')
    occupied: occupancy?.getAspect('occupancySensor').getDatum('value')

  describeStateTransition: (before, after) ->
    if after.occupied == true
      'became occupied'
    else if after.occupied == false
      'became unoccupied'
    else
      null