_ = require('underscore')
Adapter = require('../../Adapter')
IsyAPI = require('./IsyAPI')

ISY_DEVICE_CLASSES = [
  require('./IsyInsteonDimmerNode'),
  require('./IsyInsteonSwitchNode')
]

module.exports = class IsyAdapter extends Adapter
  name: 'ISY'

  # Required: host, username, password
  defaults: {}

  initialize: ->
    super
    @setValid false

  start: ->
    @_api = new IsyAPI
      host: @get('host')
      username: @get('username')
      password: @get('password')
    @_api.connect() # XXX Notice if fails, disconnects, etc
    @listenTo @_api, 'property-update', (update) =>
      targetNode = @children.get(update.node)
      if targetNode?
        targetNode.processData _.object([[update.property, update.value]])
      else
        @log 'verbose', "Unexpected property update #{JSON.stringify(update)}"
    @discover()
    # TODO There is an "ERR" property!! We should use it

  executeCommand: (node, command, args...) ->
    @_api.executeCommand node, command, args

  discover: ->
    @_api.getNodes().done (nodes) =>
      for node in nodes
        deviceType = node.type.slice(0, 2)
        deviceClass = _.find ISY_DEVICE_CLASSES,
          (klass) -> klass.matchesType(deviceType)
        if deviceClass?
          @log 'debug', "Instantiating node #{node.address} (#{node.name}) " +
            "as #{deviceClass.prototype.key}"
          ourNode = new deviceClass({id: node.address}, {adapter: this})
          @children.add ourNode
          ourNode.processData node.properties
        else
          @log 'warn', "Ignoring node #{node.address} (#{node.name}) - " +
            "no match for device type #{deviceType.join('.')}"
      @setValid true