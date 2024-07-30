
[AdapterNode] = require('../../AdapterNode')
lgtv = require('lgtv-ip-control');

module.exports = class LGTVNode extends AdapterNode
  aspects:
    powerOnOff:
      commands:
        set: (node, value) ->
          node.setPower(value).then ->
            node.getAspect('powerOnOff').setData state: value

  initialize: ->
    super
    @setValid false
    @_api = new lgtv.LGTV(@get('host'), @get('mac'), @get('keycode'))

  setPower: (power) ->
    if power
      @_api.connect().then ->
        @_api.powerOn().then ->
          @_api.disconnect()
    else
      @_api.powerOff()
