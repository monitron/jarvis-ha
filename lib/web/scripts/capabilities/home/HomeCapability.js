const _ = require('underscore');
const [Capability] = require('../../Capability.js');
const HomeCapabilityView = require('./HomeCapabilityView.js');

module.exports = class HomeCapability extends Capability {
  name = 'Home';
  icon = 'home';
  view = HomeCapabilityView;

  allShortcuts() {
    return _.chain(window.app.capabilities.map((cap) => cap.shortcuts()))
      .flatten()
      .sortBy('priority')
      .value();
  }
}
