[AdapterNode] = require('../../AdapterNode')
esphome = require('@2colors/esphome-native-api')
_ = require('underscore')

ENTITY_CLASSES = [
  require('./ESPHomeCoverNode'),
  require('./ESPHomeButtonNode'),
  require('./ESPHomeLightNode')
]

module.exports = class ESPHomeDeviceNode extends AdapterNode
  initialize: ->
    super
    @setValid false
    @_client = new esphome.Client({host: @get('host')})
    @_client.connect()
    @_client.on 'initialized', =>
      @log 'verbose', "Connected!"
      @setValid true
    @_client.on 'disconnected', =>
      @log 'verbose', "Disconnected."
      @setValid false
    @_client.on 'newEntity', (entity) =>
      @log 'verbose', "Found entity '#{entity.name}' type #{entity.type}"
      deviceClass = _.find ENTITY_CLASSES, (klass) -> klass.prototype.entityType == entity.type
      if deviceClass
        @children.add new deviceClass({id: entity.name, entity: entity}, {adapter: this})
      else
        @log 'verbose', "No entity node available for type #{entity.type}"
