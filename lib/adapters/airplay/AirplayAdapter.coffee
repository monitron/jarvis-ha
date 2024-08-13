pyatv = require('@sebbo2002/node-pyatv')
Adapter = require('../../Adapter')
AirplayNode = require('./AirplayNode')

module.exports = class AirplayAdapter extends Adapter
  name: 'AirPlay'

  # Each device needs 'host' and 'name'
  defaults:
    devices: {}

  start: ->
    api = pyatv.default
    for id, details of @get('devices')
      @log 'verbose', "Building node #{id}"
      device = api.device(details)
      attrs = Object.assign({id: id, device: device})
      @children.add new AirplayNode(attrs, {adapter: this})
