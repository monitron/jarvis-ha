
Adapter = require('../../Adapter')
DenonAVRNode = require('./DenonAVRNode')

module.exports = class DenonAVRAdapter extends Adapter
  name: 'Denon AVR'

  # Each receiver needs:
  # - host
  defaults:
    receivers: {}
    pollInterval: 5 # seconds between status data refreshes

  start: ->
    for id, details of @get('receivers')
      @log 'verbose', "Building Receiver node #{id}"
      attrs = Object.assign({id: id}, details)
      @children.add new DenonAVRNode(attrs, {adapter: this})
