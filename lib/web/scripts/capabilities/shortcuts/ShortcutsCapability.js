
const [Capability] = require('../../Capability.js');
const ShortcutsCapabilityView = require('./ShortcutsCapabilityView.js');

module.exports = class ShortcutsCapability extends Capability {
  name = 'Shortcuts';
  icon = 'th-large';
  view = ShortcutsCapabilityView;
}
