_ = require('underscore')
moment = require('moment')

[AdapterNode] = require('../../AdapterNode')
OccupantsIndividualNode = require('./OccupantsIndividualNode')

module.exports = class OccupantsNode extends AdapterNode
  key: 'occupants'

  # Each person is tracked using their networkPresence node, which ideally
  # should map to a phone or something else the person always carries, doesn't
  # turn off and which connects to the home network (i.e. Wi-Fi) as soon as they
  # arrive at home.
  #
  # At the same time, we watch the exits (doors with open/close sensors) to
  # corroborate instances of coming and going.
  #
  # A child is created for each person, each with an occupantSensor aspect.
  # Each occupantSensor value is an object with these keys:
  # - state:     <boolean> if true, we think this person is an occupant
  # - confident: <boolean> if true, we're pretty sure that we're right
  # - since:     <ISO8601 date string> when we think person left or arrived
  #              (undefined if we have no idea)
  #
  # On startup, anyone with network presence is marked
  #   state: true,  confident: true
  # ...and anyone without network presence is marked
  #   state: false, confident: false
  #
  # If network presence is lost around when a door is open, we mark:
  #   state: false, confident: true,  since: <door open time>
  # If network presence is lost but no door opens, we mark:
  #   state: false, confident: false, since: <presence loss time>
  #
  # If network presence is gained around when a door is open, we mark:
  #   state: true,  confident: true,  since: <door open time>
  # If network presence is gained but no door opens, we mark:
  #   state: true,  confident: true,  since: <presence gain time>
  #
  # If network presence is lost and regained within configured networkGraceTime,
  # no change is made to the person's state, regardless of any door openings.

  defaults:
    people: {} # name: { networkPresence: [path to a node with a
               #         networkPresenceSensor aspect] }
    doors:  [] # A list of paths with openCloseSensor aspects
    networkGraceTime:  120 # (sec) time a device can be on/off the network
                           # before we consider it to be here/gone
    maxExitLagTime:    900 # (sec) max time after an door open that a following
                           # network presence loss may be considered related
    maxExitLeadTime:   120 # (sec) max time before an door open that a preceding
                           # network presence loss may be considered related
    maxEnterLagTime:   300 # (sec) max time after an door open that a following
                           # network presence gain may be considered related
    maxEnterLeadTime:  180 # (sec) max time before an door open that a preceding
                           # network presence gain may be considered related
    processInterval:    10 # (sec) how often to calculate changes

  initialize: ->
    super
    @_pendingChanges = []
    for id, conf of @get('people')
      @children.add new OccupantsIndividualNode({id: id}, {adapter: this})
      # Watch network presence sensor state
      @server.adapters.onEventAtPath conf.networkPresence, 'aspectData:change',
        (aspectId, data) =>
          if aspectId == 'networkPresenceSensor'
            @handleNewNetworkState(id, data.value)
      # Try to set initial state
      netNode = @server.adapters.getPath(conf.networkPresence)
      if netNode.isValid()
        datum = netNode.getAspect('networkPresenceSensor')?.getDatum('value')
        if datum? then @handleNewNetworkState(id, datum)
    for door in @get('doors')
      @server.adapters.onEventAtPath door, 'aspectData:change',
        (aspectId, data) => @handleDoorChange(aspectId, data)
    setInterval((=> @calculate()), @get('processInterval') * 1000)

  handleDoorChange: (aspectId, data) ->
    if aspectId == 'openCloseSensor' and data.state == true # Door has opened
      @_lastDoorOpen = moment()

  handleNewNetworkState: (personId, state) ->
    person = @children.get(personId)
    currentValue = person.getAspect('occupantSensor').getData()
    if currentValue? # Consider an update
      # Does this contradict an existing change during the networkGraceTime?
      change = _.findWhere(@_pendingChanges, {person: personId})
      if change? # Yes, cancel it
        @_pendingChanges = _.without(@_pendingChanges, change)
      else # No, this is new
        @_pendingChanges.push person: personId, state: state, time: moment()
    else # This is the initial state...set immediately
      # we're confident about presence but not about absence
      person.processData state: state, confident: state

  calculate: ->
    now = moment()
    toClear = []
    for change in @_pendingChanges
      # Don't even consider changes that are newer than networkGraceTime
      if now.diff(change.time) >= @get('networkGraceTime') * 1000
        # Does the current lastDoorOpen fall in range?
        if change.state
          lag  = @get('maxEnterLagTime')  * 1000
          lead = @get('maxEnterLeadTime') * 1000
        else
          lag  = @get('maxExitLagTime')   * 1000
          lead = @get('maxExitLeadTime')  * 1000
        if @_lastDoorOpen? and @_lastDoorOpen.diff(change.time) < lead and (
          change.time.diff(@_lastDoorOpen) < lag)
          # Door opening matches with this network event
          toClear.push change
          @children.get(change.person).processData
            state: change.state
            confident: true
            time: @_lastDoorOpen
        else if now.diff(change.time) > lead
          # No future door open can match with this network event
          toClear.push change
          @children.get(change.person).processData
            state: change.state
            confident: change.state # we're sure about gains, but not losses
            time: change.time
    @_pendingChanges = _.without(@_pendingChanges, toClear...)
