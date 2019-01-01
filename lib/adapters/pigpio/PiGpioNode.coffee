[AdapterNode] = require('../../AdapterNode')

module.exports = class PiGpioNode extends AdapterNode
  connection: ->
    @adapter.connection(@get('daemon'))

  pullUpDown: (resistor) ->
    {none: 0, down: 1, up: 2}[resistor]