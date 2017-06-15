_ = require('underscore')

[Capability] = require('../Capability')

module.exports = class CamerasCapability extends Capability
  name: "Cameras"

  # Cameras can have: name, stillPath, stillInterval
  defaults:
    cameras: {}
    thumbnailStillInterval: 5
    expandedStillInterval: 2

  cameraDefaults:
    stillInterval: 30

  start: ->
    @setValid true

  camerasState: ->
    states = {}
    for cameraId, details of @get('cameras')
      details = _.defaults({}, details, @cameraDefaults)
      if details.stillPath?
        aspect = @_server.adapters.getPath(details.stillPath)?.
          getAspect('stillCamera')
        if aspect? then details.still = aspect.getData()
      states[cameraId] = details
    states

  _getState: ->
    cameras: @camerasState()