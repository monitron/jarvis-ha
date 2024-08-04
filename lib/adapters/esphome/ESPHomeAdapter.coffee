_ = require('underscore')
Q = require('q')
Adapter = require('../../Adapter')
ESPHomeDeviceNode = require('./ESPHomeDeviceNode')

module.exports = class ESPHomeAdapter extends Adapter
  name: 'ESPHome'

  # Required: devices (object)
  # Required for each device value: host
  defaults:
    devices: {}

  initialize: ->
    super
    @setValid false

  start: ->
    for id, details of @get('devices')
      @log 'verbose', "Building device node #{id}"
      attrs = Object.assign({id: id}, details)
      @children.add new ESPHomeDeviceNode(attrs, {adapter: this})
    @setValid true