[Capability] = require('../Capability')

module.exports = class ShortcutsCapability extends Capability
  name: "Shortcuts"

  start: ->
    # no-op server side thus far
    @setValid true