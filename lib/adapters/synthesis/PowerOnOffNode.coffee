_ = require('underscore')
Q = require('q')
[AdapterNode] = require('../../AdapterNode')

module.exports = class PowerOnOffNode extends AdapterNode
  key: 'powerOnOff'

  defaults:
    operator: 'or'
    switches: [] # paths of nodes with powerOnOff aspects

  aspects:
    powerOnOff:
      commands:
        set: (node, value) -> node.switchAll(value)

  initialize: ->
    super
    for sw in @get('switches')
      @server.adapters.onEventAtPath sw, 'valid:change', =>
        @updateValidity()
      @server.adapters.onEventAtPath sw, 'aspectData:change', =>
        @handleInputChange()
    @updateValidity()
    @handleInputChange()

  handleInputChange: ->
    return unless @isValid()
    ourAspect = @getAspect('powerOnOff')
    inputs = (@server.adapters.getPath(sw).getAspect('powerOnOff').getDatum('state') for sw in @get('switches'))
    isOn = if @get('operator') == 'and'
      _.every(inputs)
    else
      _.some(inputs)
    ourAspect.setData state: isOn

  updateValidity: ->
    @setValid _.every(@get('inputs'), (input) =>
      @server.adapters.getPath(input)?.isValid())
    if @isValid() then @handleInputChange()

  switchAll: (value) ->
    d = Q.defer()
    Q.all(@server.adapters.getPath(sw)?.getAspect('powerOnOff')?.executeCommand("set", value) for sw in @get('switches'))
      .fail -> d.reject()
      .then -> d.resolve()
    d.promise