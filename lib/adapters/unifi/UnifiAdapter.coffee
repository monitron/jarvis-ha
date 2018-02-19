
Adapter = require('../../Adapter')
Unifi = require('ubnt-unifi')
UnifiClientNode = require('./UnifiClientNode')
_ = require('underscore')

module.exports = class UnifiAdapter extends Adapter
  name: "UniFi"

  defaults:
    port: 8443
    site: 'default'
    wifiClients: []  # A list of MAC addresses for wi-fi clients whose
                     # comings and goings we want to notice.
    pollInterval: 60 # (sec) how often to request statistics
    # host, username and password (strings) required

  initialize: ->
    super
    @setValid false

  start: ->
    unless @has('host') and @has('username') and @has('password')
      @log 'error', 'Cannot continue without host, username and password'
    else
      for mac in @get('wifiClients')
        @children.add new UnifiClientNode({id: mac}, {adapter: this})
      @_unifi = new Unifi
        host: @get('host')
        port: @get('port')
        username: @get('username')
        password: @get('password')
        site: @get('site')
        insecure: true
      @_unifi.on 'ctrl.connect', =>
        @log 'verbose', "Connected to #{@get('host')}"
        @setValid true
      @_unifi.on 'ctrl.disconnect', =>
        @log 'verbose', "Disconnected from #{@get('host')}"
        @setValid false
      @_unifi.on 'ctrl.error', (error) => @log 'warn', "error! #{error}"
      @_unifi.on 'wu.*', (data) => @handleEvent(data)
      setInterval (=> @pollStats()), @get('pollInterval') * 1000
      @pollStats()

  pollStats: ->
    @_unifi.get('stat/sta').then (data) =>
      @log 'verbose', 'Processing poll results'
      for mac in @get('wifiClients')
        node = _.findWhere(data.data, mac: mac)
        @children.get(mac).processData(node?.signal? or false)

  handleEvent: (event) ->
    switch event.key
      when 'EVT_WU_Connected'
        @log 'verbose', "Event - connected: #{event.user}"
        @children.get(event.user)?.processData true
      when 'EVT_WU_Disconnected'
        @log 'verbose', "Event - disconnected: #{event.user}"
        @children.get(event.user)?.processData false
