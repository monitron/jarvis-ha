
_ = require('underscore')
Backbone = require('backbone')

class SecurityRule extends Backbone.Model
  defaults:
    connections: {}
    parameters: {}
    modes: {}

  defaultParameters: {}

  defaultModeParameters: {}

  initialize: (attrs, options) ->
    @_parent = options.parent
    @_server = options.server
    @set 'parameters', _.defaults(@get('parameters'), @defaultParameters)

    # Notice when security mode changes
    @listenTo @_parent, 'mode:change', => @trigger 'mode:change'

    # Notice when our connections' data changes
    for path in @getUniqueConnectionPaths()
      @_server.adapters.onEventAtPath path, 'aspectData:change',
        (args...) => @trigger('connection:change', args...)

    @listenTo this, 'mode:change', @cancelDelayTimeout
    @listenTo this, 'mode:change connection:change', @evaluate

  # Override me with a method that tests whether the rule is currently
  # triggering. This method won't be called unless the rule is valid (all
  # its connections are valid). Return null if the state cannot be determined.
  state: ->
    undefined

  isValid: ->
    _.every @getUniqueConnectionPaths(), (path) =>
      p = @_server.adapters.getPath(path)
      unless p? then @log 'warn', "Connected path #{path} is missing"
      p?

  evaluate: ->
    if !@isValid()
      @log 'warn', 'Unable to evaluate - rule not currently valid'
      return
    mode = @currentModeParameters()
    state = @state()
    if !state?
      @log 'debug', "State cannot be determined"
      @cancelDelayTimeout()
      # XXX Do something real
    else if state and mode.eventImportance?
      if @ongoingEvent?
        if @ongoingEvent.get('importance') != mode.eventImportance
          # The ongoing event is of the wrong importance; replace it
          @endOngoingEvent()
          @createOngoingEvent()
      else # There is no event, and there should be (now or soon)
        if mode.eventDelay?
          if !@delayTimeout? # If delay has already begun, leave it be
            @delayTimeout = setTimeout((=> @createOngoingEvent()),
              mode.eventDelay * 1000)
            @log 'debug', "Event will fire in #{mode.eventDelay}s."
        else
          @createOngoingEvent()
    else
      @cancelDelayTimeout()
      if @ongoingEvent?
        @endOngoingEvent() # This event is no longer appropriate
    @trigger 'change', this # XXX Only change if state actually changed

  currentModeParameters: ->
    @get('modes')[@_parent.mode] or {}

  getConnectionTarget: (connId) ->
    path = @get('connections')[connId]
    return undefined unless path?
    @_server.adapters.getPath(path)

  getUniqueConnectionPaths: ->
    uniquePaths = []
    for path in _.values(@get('connections'))
      uniquePaths.push(path) unless _.find(uniquePaths, (p) -> _.isEqual(p, path))
    uniquePaths

  cancelDelayTimeout: ->
    if @delayTimeout?
      @log 'debug', 'Delay timeout cancelled.'
      clearTimeout(@delayTimeout)
    delete @delayTimeout

  createOngoingEvent: (importance) ->
    @cancelDelayTimeout()
    @ongoingEvent = @_parent.createEvent
      importance: @currentModeParameters().eventImportance
      title: @buildMessage('presentTitle')

  endOngoingEvent: ->
    @ongoingEvent.set
      end: new Date()
      title: @buildMessage('pastTitle')
    delete @ongoingEvent

  stateDescription: ->
    state = @state()
    if state
      @buildMessage('presentTitle')
    else if !state?
      @buildMessage('unknownTitle')
    else
      undefined

  buildMessage: (msgParam) ->
    params = @get('parameters')
    # Later we might pass more data than just the params
    _.template(params[msgParam])(params)

  toStateJSON: ->
    state: @state()
    description: @stateDescription()

  log: (level, message) ->
    @_parent.log level, "[#{@get('id')} rule(#{@get('type')})] #{message}"

class SecurityRules extends Backbone.Collection
  model: SecurityRule

module.exports = [SecurityRule, SecurityRules]