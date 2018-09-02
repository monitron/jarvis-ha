_ = require('underscore')
Adapter = require('../../Adapter')
MirrorHostNode = require('./MirrorHostNode')

module.exports = class MirrorAdapter extends Adapter
  name: 'Mirror'

  defaults:
    hosts: {}

  start: ->
    for id, attrs of @get('hosts')
      attrs = _.defaults({id: id}, attrs)
      @children.add new MirrorHostNode(attrs, {adapter: this})