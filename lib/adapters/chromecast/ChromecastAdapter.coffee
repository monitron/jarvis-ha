Adapter = require('../../Adapter')
DefaultMediaReceiver = require('castv2-client').DefaultMediaReceiver
mdns = require('mdns-js')
ChromecastDeviceNode = require('./ChromecastDeviceNode')

module.exports = class ChromecastAdapter extends Adapter
  name: 'Chromecast'

  initialize: ->
    super
    @setValid false

  start: ->
    @_browser = mdns.createBrowser(mdns.tcp('googlecast'))
    @_browser.on 'ready', => @_browser.discover()
    @_browser.on 'update', (data) => @_onMDNSDiscovery(data)
    @setValid true

  _onMDNSDiscovery: (data) ->
    return unless data.type[0].name == 'googlecast' and data.txt?
    txt = {}
    for item in data.txt
      [id, value] = item.split('=', 2)
      txt[id] = value
    device =
      id: txt.id
      address: data.addresses[0]
      name: txt.fn
    # TODO handle case where Chromecast changes address or name
    unless @children.get(device.id)?
      @log 'debug', "Discovered id #{device.id} (#{device.name}) at " +
        "#{device.address}"
      @children.add new ChromecastDeviceNode(device, {adapter: this})