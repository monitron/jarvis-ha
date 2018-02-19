_ = require('underscore')
moment = require('moment')

[Capability] = require('../../Capability')

module.exports = class PeopleCapability extends Capability
  name: "People"

  # People have: name, occupantSensor
  defaults:
    people: {}

  start: ->
    _.each @get('people'), (person, id) =>
      if person.occupantSensor?
        @_server.adapters.onEventAtPath person.occupantSensor,
          'aspectData:change', (aspectId, data, oldData) =>
            if aspectId == 'occupantSensor'
              @handleOccupancyChange id, data, oldData
    @setValid true # XXX Notice validity of sources

  peopleState: ->
    for id, config of @get('people')
      state = id: id, name: config.name
      if config.occupantSensor?
        aspect = @_server.adapters.getPath(config.occupantSensor)?.
          getAspect('occupantSensor')
        if aspect? then state.occupancy = aspect.getData()
      state

  handleOccupancyChange: (personId, data, oldData) ->
    @trigger 'change', this
    if oldData.state? and data.state? and data.state != oldData.state
      chunks = [@get('people')[personId].name]
      if !data.confident then chunks.push 'probably'
      if data.state then chunks.push 'came home' else chunks.push 'left home'
      date = if data.time? then moment(data.time).toDate() else new Date()
      event =
        importance: 'routine'
        title: chunks.join(' ')
        start: date
      @createEvent event, true

  _getState: ->
    people: @peopleState()
