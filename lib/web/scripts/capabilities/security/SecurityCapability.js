const [Capability] = require('../../Capability.js');
const SecurityCapabilityView = require('./SecurityCapabilityView.js');

module.exports = class ComfortCapability extends Capability {
  name = 'Security';
  icon = 'shield';
  view = SecurityCapabilityView;
}
