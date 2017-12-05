const [Capability] = require('../../Capability.js');
const HomeCapabilityView = require('./HomeCapabilityView.js');

module.exports = class HomeCapability extends Capability {
  name = 'Home';
  icon = 'home';
  view = HomeCapabilityView;
}
