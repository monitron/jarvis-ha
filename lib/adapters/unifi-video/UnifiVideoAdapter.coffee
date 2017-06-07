
Adapter = require('../../Adapter')
UnifiCameraNode = require('./UnifiCameraNode')

module.exports = class UnifiVideoAdapter extends Adapter
  name: 'UniFi Video'

  # Required: host, cameras, apiKey
  defaults:
    cameras: []
    apiPort: 7080

  start: ->
    for camera in @get('cameras')
      @log 'verbose', "Building camera node #{camera}"
      @children.add new UnifiCameraNode({id: camera}, {adapter: this})

  apiBaseUrl: ->
    "http://#{@get('host')}:#{@get('apiPort')}/api/2.0/"