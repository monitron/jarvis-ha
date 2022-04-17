_ = require('underscore')
Q = require('q')
Adapter = require('../../Adapter')
leap = require('lutron-leap')

DEVICE_CLASSES = [
  require('./RadioRA3DimmerNode')
]

module.exports = class RadioRA3Adapter extends Adapter
  name: 'RadioRA3'

  # Required: host, ca, certificate, private-key
  defaults: {}

  initialize: ->
    super
    @setValid false

  start: ->
    @log 'verbose', 'Connecting to LEAP host'
    @_api = new leap.LeapClient(@get('host'), leap.LEAP_PORT, @get('ca'),
      @get('private-key'), @get('certificate'))
    @_api.connect().then =>
      @_loadAreas()
      @_api.subscribe "/zone/status", (r) => @_processMultiZoneStatus(r)

  doZoneCommand: (zone, command) ->
    deferred = Q.defer()
    promise = @_api.request "CreateRequest",
      "/zone/#{zone}/commandprocessor",
      Command: command
    promise
      .then => deferred.resolve()
      .catch (err) => deferred.reject(err)
    deferred.promise

  _loadAreas: ->
    @_api.request("ReadRequest", "/area").then (result) =>
      result.Body.Areas.forEach (area, index) =>
        if area.IsLeaf
          @log 'verbose', "Loading zones for area #{area.href} #{area.Name}"
          @_loadZonesForArea(area.href)
    @setValid true # Doesn't actually wait for full enumeration

  _loadZonesForArea: (areaUri) ->
    p = @_api.request "ReadRequest", "#{areaUri}/associatedzone"
    p.then (result) =>
      @log 'verbose', JSON.stringify(result)
      if result.Header.StatusCode.code == 200
        for zone in result.Body.Zones
          id = @_hrefToId(zone.href)
          klass = _.find(DEVICE_CLASSES, (k) ->
            k.prototype.type == zone.ControlType)
          if klass?
            @log 'verbose', "Adding node for zone #{id} (#{zone.Name}) " +
              "type #{zone.ControlType}"
            newNode = new klass({id: id}, {adapter: this})
            @children.add newNode
          else
            @log 'warn', "Ignoring node #{id} - no match for control type #{zone.ControlType}"

  _processMultiZoneStatus: (message) ->
    for status in message.Body.ZoneStatuses
      id = @_hrefToId(status.Zone.href)
      targetNode = @children.get(id)
      if targetNode?
        targetNode.processData status
      else
        @log 'verbose', "Ignoring update for unknown zone #{id}"

  _hrefToId: (href) ->
    String(href.split("/")[2])
