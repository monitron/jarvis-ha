[Control] = require('../Control')

module.exports = class OccupancySensorControl extends Control
  _getState: ->
    occupancy = @getConnectionTarget('occupancySensor')
    occupied: occupancy?.getAspect('occupancySensor').getDatum('value')

# Super chatty and not useful
#  describeStateTransition: (before, after) ->
#    if after.occupied == true
#      'became occupied'
#    else if after.occupied == false
#      'became unoccupied'
#    else
#      null