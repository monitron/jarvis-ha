
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
    eventStreamTimeout: 60 # seconds to wait before assuming connection is gone
    eventStreamReconnectInterval: 60 # seconds to wait between connect attempts

  start: ->
    for id, details of @get('stations')
      @log 'verbose', "Building station node #{id}"
      attrs = Object.assign({
        id: id,
        eventStreamTimeout: @get('eventStreamTimeout'),
        eventStreamReconnectInterval: @get('eventStreamReconnectInterval')
      }, details)
      @children.add new DoorBirdStationNode(attrs, {adapter: this})
