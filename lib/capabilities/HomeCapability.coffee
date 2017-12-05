[Capability] = require('../Capability')

module.exports = class HomeCapability extends Capability
  name: "Home"

  start: ->
    # no-op server side
    @setValid true
