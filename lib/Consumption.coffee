
Backbone = require('backbone')
uuid = require('uuid/v4')

# Consumption reports consumption rate of a resource
# such as liters per minute of water or watts of electricity

# capabilityId: string; id of capability which generated this report
# node:         string; capability's id for the resource user
# name:         string: human-readable resource user name
# category:     string; human-readable usage category name
# resourceType: string; electricity, natural-gas, water, sewer
# rate:         number; watts        ?            L/min, L/min

class Consumption extends Backbone.Model
  initialize: ->
    unless @has('id') then @set 'id', uuid()

class Consumptions extends Backbone.Collection
  model: Consumption

module.exports = [Consumption, Consumptions]