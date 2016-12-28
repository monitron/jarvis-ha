[Capability] = require('../Capability')
[SecurityRule, SecurityRules] = require('./SecurityRule')
rules = require('./rules')

module.exports = class SecurityCapability extends Capability
  name: "Security"

  defaults:
    modes: {}
    rules: []

  start: ->
    # Instantiate rules
    @rules = new SecurityRules()
    for ruleConfig in @get('rules')
      @rules.add new rules[ruleConfig.type](ruleConfig)
    @setValid true # XXX Notice if sources become invalid