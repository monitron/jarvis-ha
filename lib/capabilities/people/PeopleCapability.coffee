_ = require('underscore')
Q = require('q')
moment = require('moment')

[Capability] = require('../../Capability')

module.exports = class PeopleCapability extends Capability
  name: "People"

  # People have: name, occupantSensor
  defaults:
    people: {}

  naturalCommands:
    listPeople:
      forms: [
        "(who is|who's)( at)? (home|here|the house|around|in)",
        "(where is|where's) every(one|body)( at)?",
        "is (every|any)(one|body) (home|here|the house|around|in)"]
      execute: (cap) -> Q.fcall -> cap.describeOccupancy()
    personStatus:
      forms: [
        "(where is|where's) <person>( at)?",
        "is <person> (at )?(home|here|the house|around|in)",
        "(when )?did <person> (leave|go|arrive|get|make it)( home| here| in)?"]
      resolve: (cap, {person}) ->
        person = cap.resolvePersonName(person)
        if person? then {person: person} else null
      execute: (cap, {person}) -> Q.fcall -> cap.describePerson(person)


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

  resolvePersonName: (name) ->
    name = name.toLowerCase()
    _.findKey(@get('people'), (person) -> person.name.toLowerCase() == name)

  describePerson: (personId) ->
    person = _.findWhere(@peopleState(), id: personId)
    state = @_describePersonState(person)
    "#{person.name} is #{state}."

  describeOccupancy: ->
    states = _.chain(@peopleState())
      .map((person) =>
        name: person.name
        state: @_describePersonState(person))
      .groupBy('state')
      .map((people, state) =>
        list = @_englishList(_.pluck(people, 'name'))
        verb = if people.length == 1 then 'is' else 'are'
        "#{list} #{verb} #{state}.")
      .value()
    states.join(' ')

  _describePersonState: (state) ->
    if state.occupancy? and state.occupancy?.state?
      d = if state.occupancy.state then 'home' else 'away'
      if !state.occupancy.confident then d = "probably #{d}"
      d
    else
      'unknown'

  _englishList: (things) ->
    if things.length == 1
      things[0]
    else
      head = things.slice(0, -1).join(', ')
      [head, things.slice(-1)[0]].join(" and ")

  _getState: ->
    people: @peopleState()
