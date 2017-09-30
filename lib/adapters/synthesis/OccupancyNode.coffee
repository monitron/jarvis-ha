_ = require('underscore')
[AdapterNode] = require('../../AdapterNode')

module.exports = class OccupancyNode extends AdapterNode
  key: 'occupancy'

  defaults:
    operator: 'or'
    inputs: []

  aspects:
    occupancySensor: {}

  initialize: ->
    super
    for input in @get('inputs')
      @server.adapters.onEventAtPath input.path, 'valid:change', =>
        @updateValidity()
      @server.adapters.onEventAtPath input.path, 'aspectData:change', =>
        @handleInputChange()
    @updateValidity()
    @handleInputChange()

  handleInputChange: ->
    return unless @isValid()
    ourAspect = @getAspect('occupancySensor')
    inputs = (@inputReadsOccupied(input) for input in @get('inputs'))
    occupied = if @get('operator') == 'and'
      _.every(inputs)
    else
      _.some(inputs)
    if occupied
      if @_timeout?
        clearTimeout @_timeout
        delete @_timeout
      ourAspect.setData value: true
    else if @has('gracePeriod') and ourAspect.getDatum('value')
      unless @_timeout?
        @_timeout = setTimeout((=> @eventuallySetUnoccupied()),
          @get('gracePeriod') * 1000)
    else
      ourAspect.setData value: false

  inputReadsOccupied: (input) =>
    node = @server.adapters.getPath(input.path)
    switch input.type
      when 'open'
        node.getAspect('openCloseSensor').getDatum('state')
      else
        node.getAspect('occupancySensor').getDatum('value')

  updateValidity: ->
    @setValid _.every(@get('inputs'), (input) =>
      @server.adapters.getPath(input.path)?.isValid())
    if @isValid()
      @handleInputChange()
    else
      clearTimeout @_timeout
      delete @_timeout

  eventuallySetUnoccupied: ->
    delete @_timeout
    @getAspect('occupancySensor').setData value: false
