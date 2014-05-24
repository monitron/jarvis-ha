
Adapter = require('../../Adapter')
InsteonDimmerNode = require('./InsteonDimmerNode')

module.exports = class InsteonAdapter extends Adapter
  name: "Insteon"
  configDefaults:
    "gateway-port": 9761

  start: ->
    # Do the connect thing