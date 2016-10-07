
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
      stations: {}
    };
  }

  initialize() {
    // Where to (initially)?
    if(this.hasHome()) {
      this.goHome();
    } else if(this.has('defaultPath')) {
      this.set('path', this.get('defaultPath'));
    } 
  }

  pathName() {
    return this.has('path') && _.last(this.get('path'));
  }

  controls() {
    return window.app.controls;
  }

  hasHome() {
    return this.stationConfig().hasOwnProperty('homePath')
  }

  isAtHome() {
    return _.isEqual(this.get('path'), this.stationConfig()['homePath']);
  }

  goHome() {
    this.set('path', this.stationConfig()['homePath']);
  }

  stationConfig() {
    const station = window.app.get('station');
    if(station == null) return {};
    return this.get('stations')[station] || {};
  }
}
