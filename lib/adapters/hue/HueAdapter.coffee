HueApi = require("node-hue-api").HueApi

Adapter = require('../../Adapter')
[AdapterNode] = require('../../AdapterNode')
HueLightNode = require('./HueLightNode')
HueGroupNode = require('./HueGroupNode')

module.exports = class HueAdapter extends Adapter
  name: 'Hue'

  defaults:
    pollInterval:          5  # seconds
    discoverRetryInterval: 60 # seconds
    # required: host, username

  start: ->
    @setValid false
    @_api = new HueApi(@get('host'), @get('username'))
    @discover()

  discover: ->
    lightsNode = @children.add new AdapterNode({id: 'lights'}, {adapter: this})
    groupsNode = @children.add new AdapterNode({id: 'groups'}, {adapter: this})
    @log 'verbose', "Discovering Hue lights and groups on #{@get('host')}"
    @_api.fullState()
      .then (result) =>
        for id, details of result.lights
          @log 'verbose', "Discovered light #{id}"
          node = lightsNode.children.add new HueLightNode({id: id}, {adapter: this})
          node.processData details.state
        for id, details of result.groups
          @log 'verbose', "Discovered group #{id}"
          node = groupsNode.children.add new HueGroupNode(
            {id: id, lights: details.lights}, {adapter: this})
          # Data for these will be populated on first poll
        @setValid true
        setInterval (=> @poll()), @get('pollInterval') * 1000
      .fail (err) =>
        @log 'error', "Unable to discover Hue devices, will try again (#{err})"
        setTimeout (=> @discover()), @get('discoverRetryInterval') * 1000
      .done()

  setLightState: (id, state) ->
    @_api.setLightState id, state

  setGroupState: (id, state) ->
    @_api.setGroupLightState id, state

  poll: ->
    @_api.lights()
      .then (result) =>
        for light in result.lights
          @children.get('lights').children.get(light.id)?.processData light.state
        # Each group is fed the entire lights state, from which it synthesizes
        # its own state. This will break if the bridge's group config changes
        @children.get('groups').children.each (group) =>
          group.processData result.lights
        @setValid true
      .fail (err) =>
        @log 'warn', "Failed polling: #{err}"
        @setValid false
      .done()
