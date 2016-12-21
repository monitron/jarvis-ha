
[AdapterNode] = require('../../AdapterNode')

# This is an abstract Ecobee node
module.exports = class EcobeeNode extends AdapterNode
  _convertTemp: (apiTemp) ->
    ((Number(apiTemp) / 10.0) - 32) * (5 / 9.0)