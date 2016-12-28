
Backbone = require('backbone')

class SecurityRule extends Backbone.Model

class SecurityRules extends Backbone.Collection
  model: SecurityRule

module.exports = [SecurityRule, SecurityRules]