_ = require('underscore')
Adapter = require('../../Adapter')

SYNTHESIS_NODE_CLASSES = [
  require('./OccupancyNode'),
  require('./OccupantsNode')
]

module.exports = class SynthesisAdapter extends Adapter
  name: 'Synthesis'

  defaults:
    nodes: {}

  start: ->
    for id, attrs of @get('nodes')
      nodeClass = _.find SYNTHESIS_NODE_CLASSES,
        (klass) -> klass.prototype.key == attrs.type
      if nodeClass?
        attrs = _.defaults({id: id}, attrs)
        @children.add new nodeClass(attrs, {adapter: this})
      else
        @log 'error', "Ignoring node #{id} with unknown type #{attrs.type}"