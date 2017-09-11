_ = require('underscore')
[Capability] = require('../Capability')

module.exports = class EnergyCapability extends Capability
  name: "Energy"

  defaults:
    meters: {} # {meter: {sources: {period: [path], ...}, ...}, ...}
    idlePeriod: 'day'
    wastefulControlDelay: 360 # wait 5 minutes

  start: ->
    # Listen to all our meter sources
    for meterName, meterDetails of @get('meters')
      for period, path of meterDetails.sources
        @_server.adapters.onEventAtPath path,
          'aspectData:change', => @trigger 'change', this
    # Listen to controls to detect waste
    @listenTo @_server.controls, 'change', (ctrl) =>
      if ctrl.hasCommand('turnOff') or ctrl.get('type') == 'occupancySensor'
        @calculateWastefulControls()
    @calculateWastefulControls()
    setInterval((=> @manageWastefulControlEvents()), 30000)
    @setValid true # XXX Notice if sources become invalid

  summarizeMeters: ->
    data = {}
    for meterName, meterDetails of @get('meters')
      for period, path of meterDetails.sources
        aspect = @_server.adapters.getPath(path)?.getAspect('energySensor')
        if aspect?
          ((data[period] ||= {}).meters ||= {})[meterName] =
            aspect.getDatum('value')

    for period, periodData of data
      offsets = {}
      for offsetId, offset of @get('offsets')
        prod = periodData.meters[offset.productionMeter]
        cons = periodData.meters[offset.consumptionMeter]
        if prod? and cons? then offsets[offsetId] = prod / cons
      periodData.offsets = offsets
    data

  calculateWastefulControls: ->
    @_wastefulControls ||= []
    controls = @_server.controls.select (control) =>
      # Controls must be active (on) and capable of being turned off
      return false unless control.isActive() and control.hasCommand('turnOff')
      # Find occupancy controls in paths this control is a member of
      memberships = _.map(control.getUniqueMembershipPaths(), (p) -> p.join('.'))
      occupancySensorControls = @_server.controls.where(type: 'occupancySensor')
      occupancySensorControls = _.select occupancySensorControls, (osControl) =>
        !_.isEmpty(_.intersection(memberships,
          _.map(osControl.getUniqueMembershipPaths(), (p) -> p.join('.'))))
      # They should exist, and none of them should be showing Occupied
      !_.isEmpty(occupancySensorControls) and
        _.every(occupancySensorControls, (c) -> c.getState()?.occupied == false)
    wastefulControls = _.clone(@_wastefulControls)
    for control in controls
      if !_.findWhere(wastefulControls, id: control.id)?
        wastefulControls.push
          id: control.id
          name: control.get('name')
          reason: 'unoccupied'
          since: new Date()
    # Remove no longer wasteful controls
    wastefulControls = _.select wastefulControls, (control) ->
      _.find(controls, (c) -> c.id == control.id)
    if !_.isEqual(wastefulControls, @_wastefulControls)
      @_wastefulControls = wastefulControls
      @manageWastefulControlEvents()
      @trigger 'change', this

  manageWastefulControlEvents: ->
    ongoing = @ongoingEvents()
    # End ongoing events for no-longer-wasteful controls
    for event in ongoing
      unless _.findWhere(@_wastefulControls, id: event.get('reference'))?
        @log 'debug', "Ending waste event for #{event.get('reference')}"
        event.set end: new Date()
    # Create events for new wasteful controls
    now = new Date()
    delay = @get('wastefulControlDelay')
    for control in @_wastefulControls
      delayExpired = ((now - control.since) / 1000) >= delay
      hasEvent = _.find(ongoing, (event) -> event.get('reference') == control.id)
      if delayExpired and !hasEvent
        @log 'debug', "Creating waste event for #{control.id}"
        @createEvent
          importance: 'low'
          title: "#{control.name} may not need to be on"
          reference: control.id

  _getState: ->
    meters: @summarizeMeters()
    wastefulControls: @_wastefulControls
