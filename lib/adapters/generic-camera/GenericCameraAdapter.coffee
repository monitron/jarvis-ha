_ = require('underscore')
Adapter = require('../../Adapter')
GenericCameraNode = require('./GenericCameraNode')

module.exports = class GenericCameraAdapter extends Adapter
  name: 'Generic Camera'

  defaults:
    devices: {} # must have: stillUrl

  start: ->
    for id, details of @get('devices')
      @children.add new GenericCameraNode(
        _.defaults({id: id}, details), {adapter: this})
