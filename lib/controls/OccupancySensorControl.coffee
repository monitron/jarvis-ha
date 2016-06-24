[Control] = require('../Control')

module.exports = class OccupancySensorControl extends Control
  _getState: ->
    occupancy = @getConnectionTarget('occupancySensor')
    occupied: occupancy?.getAspect('occupancySensor').getDatum('value')