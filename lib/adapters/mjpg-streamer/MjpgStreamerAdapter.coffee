
Adapter = require('../../Adapter')
MjpgStreamerNode = require('./MjpgStreamerNode')

module.exports = class DoorBirdAdapter extends Adapter
  name: 'DoorBird'

  # Each stream needs:
  # - host
  # - port
  defaults:
    streams: {}

  start: ->
    for id, details of @get('streams')
      @log 'verbose', "Building stream node #{id}"
      attrs = Object.assign({id: id}, details)
      @children.add new MjpgStreamerNode(attrs, {adapter: this})
