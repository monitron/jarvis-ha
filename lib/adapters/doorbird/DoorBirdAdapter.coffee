
Adapter = require('../../Adapter')
DoorBirdStationNode = require('./DoorBirdStationNode')

module.exports = class DoorBirdAdapter extends Adapter
  name: 'DoorBird'

  # Each station needs:
  # - host
  # - username
  # - password
  defaults:
    stations: {}

  start: ->
    for id, details of @get('stations')
      @log 'verbose', "Building station node #{id}"
      attrs = Object.assign({id: id}, details)
      @children.add new DoorBirdStationNode(attrs, {adapter: this})
