[Capability] = require('../../Capability')
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
      klass = rules[ruleConfig.type]
      if klass?
        @rules.add new klass(ruleConfig, {parent: this, server: @_server})
      else
        @log 'error', "Unknown security rule type #{type}"
    @enterMode @get('initialMode')
    @setValid true # XXX Notice if sources become invalid via Rules

  enterMode: (newMode) ->
    @mode = newMode
    @trigger 'mode:change', newMode