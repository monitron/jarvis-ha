
[AdapterNode] = require('../../AdapterNode')
lgtv = require('lgtv-ip-control');

module.exports = class LGTVNode extends AdapterNode
  aspects:
    powerOnOff:
      commands:
        set: (node, value) ->
          node.setPower(value)
  
  setPower: (power) ->
    tv = new lgtv.LGTV(@get('host'), @get('mac'), @get('keycode'))
    if power
      @log 'verbose', "Attempting Wake-on-LAN to power on"
      tv.powerOn()
    else
      @log 'verbose', "Attempting power off"
      tv.connect().then ->
        tv.powerOff().then ->
          tv.disconnect()
