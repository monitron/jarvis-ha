
Adapter = require('../../Adapter')
InsteonDimmerDevice = require('./InsteonDimmerDevice')

module.exports = class InsteonAdapter extends Adapter
  name: "Insteon"
  configDefaults:
    "gateway-port": 9761

  buildDevice: (config) ->
    switch config.type
      when 'dimmer' then new InsteonDimmerDevice(config)
      else null

  start: ->
    # Do the connect thing