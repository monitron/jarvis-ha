
_ = require('underscore')
ping = require('ping')
Adapter = require('../../Adapter')
PingHostNode = require('./PingHostNode')

module.exports = class PingAdapter extends Adapter
  name: "Network Ping"
  defaults:
    interval: 120 # seconds - how often to check
    timeout: 10   # seconds - how long to wait for a response

  start: ->
    for id, host of @get('hosts')
      @log 'debug', "Will watch host #{host} as #{id}"
      @children.add new PingHostNode({id: id, host: host}, {adapter: this})
    @pingAll()
    @_interval = setInterval(_.bind(@pingAll, this), @get('interval') * 1000)

  pingAll: ->
    @log 'verbose', "Pinging #{@children.length} hosts"
    @children.each (child) =>
      host = child.get('host')
      cb = (result) =>
        @log 'verbose', "Host #{host} (id #{child.id}) result: #{result}"
        child.processData result
      ping.sys.probe(host, cb, {timeout: @get('timeout')})
