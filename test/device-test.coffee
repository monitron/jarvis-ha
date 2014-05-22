vows = require('vows')
assert = require('assert')

Device = require('../lib/Device')

vows
  .describe('Device')
  .addBatch
    'Device':
      topic: new(Device)

      'should exist': (device) ->
        assert.isTrue !!device.doSomething

  .export(module)