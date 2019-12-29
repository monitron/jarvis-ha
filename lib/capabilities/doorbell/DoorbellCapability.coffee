_ = require('underscore')
moment = require('moment')

[Capability] = require('../../Capability')

module.exports = class DoorbellCapability extends Capability
  name: "Doorbell"

  defaults:
    doors: {}

  doorDefaults:
    name: "Doorbell"
    message: "The doorbell rang."
    quietTime: 60  # seconds between doorbell announcements
    cameraStillInterval: 2 # seconds between camera refreshes

  start: ->
    _.each @get('doors'), (door, id) =>
      @_server.adapters.onEventAtPath door.bellPath,
        'aspectData:change',
        (aspectId, data) => @onBellChange(id, aspectId, data)
    @_lastRings = {}
    @setValid true

  onBellChange: (doorId, aspectId, data) =>
    return unless aspectId == "momentarySwitchSensor"
    return unless !!data.value
    door = _.defaults(@get('doors')[doorId], @doorDefaults)
    if @_lastRings[doorId]? and moment().diff(@_lastRings[doorId], 'seconds') < door.quietTime
      @log 'debug', "Doorbell #{doorId} rang again during quiet period"
      return
    @_lastRings[doorId] = moment()
    event =
      importance: 'medium'
      title: door.message
    @createEvent event, true
    @trigger 'change', this

  _getState: ->
    doors: _.mapObject(@_lastRings, (m) -> m.toDate())
