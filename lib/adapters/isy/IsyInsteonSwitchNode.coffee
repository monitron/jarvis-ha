
IsyNode = require('./IsyNode')

module.exports = class IsyInsteonSwitchNode extends IsyNode
  key: 'insteonSwitch'
  types: [[2, 42], [2, 55]]