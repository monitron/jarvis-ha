[Capability] = require('../Capability')

module.exports = class ControlBrowserCapability extends Capability
  name: "Control Browser"

  start: ->
    # no-op server side
    @setValid true