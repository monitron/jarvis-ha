_ = require('underscore')
pigpioClient = require('pigpio-client')
Adapter = require('../../Adapter')

PIGPIO_DEVICE_CLASSES = {
  openCloseSensor: require('./PiGpioOpenCloseSensorNode')
}

module.exports = class PiGpioAdapter extends Adapter
  name: 'PiGPIO'

  defaults:
    daemons: {}
    devices: {}
    retryInterval: 60

  start: ->
    @_connections = {}
    for id, details of @get('devices')
      klass = PIGPIO_DEVICE_CLASSES[details.type]
      @children.add new klass(_.defaults({id: id}, details), {adapter: this})
    _.each @get('daemons'), (host, connKey) =>
      @log 'error', "connecting to #{connKey} at #{host}"
      pigpio = pigpioClient.pigpio({host: host})
      @_connections[connKey] = pigpio
      pigpio.on 'connected', (info) =>
        @log 'verbose', "Connected to #{connKey}"
        @trigger 'daemon:connect', connKey
      pigpio.on 'error', (err) =>
        @log 'error', "Error from #{connKey}: #{err}"
      pigpio.on 'disconnected', (reason) =>
        @log 'warn', "Disconnected from #{connKey}, will try to reconnect"
        setTimeout (() => pigpio.connect()), @get('retryInterval') * 1000

  connection: (key) ->
    @_connections[key]