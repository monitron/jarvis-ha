
const _ = require('underscore');
const [Capability] = require('../../Capability.js');
const ControlBrowserCapabilityView = require('./ControlBrowserCapabilityView.js');
const [Control, Controls] = require('../../Control.coffee');

module.exports = class ControlBrowserCapability extends Capability {
  name = 'Controls';
  icon = 'sliders';
  view = ControlBrowserCapabilityView;

  defaults() {
    return {
      path: ['location', 'Main Floor', 'Living Room'] // XXXXXX
    };
  }

  pathName() {
    return this.has('path') && _.last(this.get('path'));
  }

  controls() {
    return window.app.controls;
  }
}
