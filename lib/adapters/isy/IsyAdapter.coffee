_ = require('underscore')
Adapter = require('../../Adapter')
IsyAPI = require('./IsyAPI')

ISY_DEVICE_CLASSES = [
  require('./IsyInsteonDimmerNode'),
  require('./IsyInsteonSwitchNode'),
  require('./IsyInsteonOpenCloseSensorNode'),
  require('./IsyInsteonFanMotorNode'),
  require('./IsyInsteonMotionSensorNode')
]

module.exports = class IsyAdapter extends Adapter
  name: 'ISY'

  # Required: host, username, password
  defaults:
    devices: {}
    pollInterval: 60 # seconds between complete data refreshes

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
    setInterval (=> @poll()), @get('pollInterval') * 1000
    # TODO There is an "ERR" property!! We should use it

  executeCommand: (node, command, args, expectResponse = true) ->
    @_api.executeCommand node, command, args, expectResponse

  discover: ->
    @_api.getNodes()
      .then (nodes) =>
        for node in nodes
          configuration = @get('devices')[node.address]
          if configuration?.classify?
            deviceClass = _.find ISY_DEVICE_CLASSES,
              (klass) -> klass.prototype.key == configuration.classify
          else
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
      .fail =>
        # TODO Try again?
        # TODO Mark invalid? currently unnecessary because discover is only
        #      called when we are already invalid
        @log 'error', "Could not discover nodes; abandoning"
      .done()

  poll: ->
    # XXX Notice additions or removals of devices?
    return unless @isValid()
    @_api.getNodes()
      .then (nodes) =>
        count = 0
        for node in nodes
          child = @children.get(node.address)
          if child?
            count += 1
            child.processData node.properties
        @log 'verbose', "Poll updated status of #{count} node(s)"
      .fail (err) => @log 'warn', "Failed polling: #{err}"
      .done()
