Adapter = require('../../Adapter')
BluesoundNode = require('./BluesoundNode')

module.exports = class BluesoundAdapter extends Adapter
  name: 'Bluesound'

  defaults:
    players: {}
    pollInterval: 1 # seconds

  start: ->
    for id, details of @get('players')
      @log 'verbose', "Building Player node #{id}"
      attrs = Object.assign({id: id}, details)
      @children.add new BluesoundNode(attrs, {adapter: this})
