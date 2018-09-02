Adapter = require('../../Adapter')
BLEDeviceNode = require('./BLEDeviceNode')
noble = require('noble')

module.exports = class BLEAdapter extends Adapter
  name: 'BLE'

  start: ->
    noble.on 'stateChange', (s) => @onNobleStateChange(s)
    noble.on 'discover',    (p) => @onNobleDiscover(p)

  onNobleStateChange: (state) ->
    if state == 'poweredOn'
      noble.startScanning [], true
      @setValid true
    else
      @setValid false

  onNobleDiscover: (peripheral) ->
    child = @children.get(peripheral.address)
    unless child?
      child = new BLEDeviceNode({id: peripheral.address}, {adapter: this})
      @children.add child
    child.processData peripheral