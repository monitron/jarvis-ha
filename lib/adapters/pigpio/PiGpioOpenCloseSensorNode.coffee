PiGpioNode = require('./PiGpioNode')

module.exports = class PiGpioOpenCloseSensorNode extends PiGpioNode
  aspects:
    openCloseSensor: {}

  defaults:
    invert: false # normally, 0 is closed, 1 is open. invert inverts this
    resistor: 'none' # none, up or down
    # you must set 'gpio' to the gpio pin number

  initialize: ->
    super
    @listenTo @adapter, 'daemon:connect', (daemon) =>
      if daemon == @get('daemon') # that's us!
        @log 'verbose', "Setting up input pin"
        @_gpio = @connection().gpio(@get('gpio'))
        @_gpio.modeSet 'input', =>
          @_gpio.pullUpDown @pullUpDown(@get('resistor')), =>
            @_gpio.read (err, level) => @processData level
            @_gpio.notify (level) => @processData level
            @log 'verbose', 'Good to go'

  processData: (level) ->
    level = level == 1
    if @get('invert') then level = !level
    @getAspect('openCloseSensor').setData state: level