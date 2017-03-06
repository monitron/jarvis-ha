_ = require('underscore')
[AdapterNode] = require('../../AdapterNode')

module.exports = class IsyNode extends AdapterNode
  types: []

  @matchesType: (type) ->
    for candidate in this.prototype.types
      return true if _.isEqual(candidate, type)
    false

  configuration: (key) ->
    (@adapter.get('devices')[@id] or {})[key]

  percentageToByte: (value) ->
    Math.round(value * 2.55)

  byteToPercentage: (value) ->
    value / 2.55