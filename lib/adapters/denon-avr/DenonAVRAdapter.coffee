
Adapter = require('../../Adapter')
DenonAVRNode = require('./DenonAVRNode')

module.exports = class DenonAVRAdapter extends Adapter
  name: 'Denon AVR'

  # Each receiver needs:
  # - host
  # - inputs (object mapping input IDs to human name)
  #   input IDs include: TUNER, DVD, BD, TV, SAT/CBL, MPLAY, GAME, AUX1, NET...
  #   (see https://assets.denon.com/documentmaster/us/avr1713_avr1613_protocol_v8%206%200%20(2).pdf)
  # ...and may optionally have:
  # - maxVolume (a number from 1 to 100 indicating the highest volume allowed. Volumes are scaled
  #              so that maxVolume appears as 100)
  defaults:
    receivers: {}
    pollInterval: 5 # seconds between status data refreshes

  start: ->
    for id, details of @get('receivers')
      @log 'verbose', "Building Receiver node #{id}"
      attrs = Object.assign({id: id}, details)
      @children.add new DenonAVRNode(attrs, {
        adapter: this,
        attributes: {mediaSource: {choices: details.inputs}}
      })
