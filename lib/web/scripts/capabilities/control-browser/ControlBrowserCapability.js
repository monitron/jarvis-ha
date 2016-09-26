
const [Capability] = require('../../Capability.js');
const ControlBrowserCapabilityView = require('./ControlBrowserCapabilityView.js');

module.exports = class ControlBrowserCapability extends Capability {
  name = 'Controls';
  icon = 'sliders';
  view = ControlBrowserCapabilityView;
}
