OpenZWave = require('openzwave')
Adapter = require('../../Adapter')

module.exports = class ZWaveAdapter extends Adapter
  name: 'Z-Wave'

  initialize: ->
    super
    @setValid false

  start: ->
    @_ozw = new OpenZWave(@get('device'))
    @_ozw.on 'driver ready', (homeid) =>
      @log 'debug', 'Z-Wave connected'
      @setValid true
    @_ozw.on 'driver failed', =>
      @log 'warn', 'Failed to connect Z-Wave'
    @_ozw.connect()