
const _ = require('underscore');
const [Capability] = require('../../Capability.js');
const [Control, Controls] = require('../../Control.coffee');
const ControlBrowserCapabilityView = require('./ControlBrowserCapabilityView.js');
const PowerOffCardView = require('./PowerOffCardView.js');

module.exports = class ControlBrowserCapability extends Capability {
  name = 'Controls';
  icon = 'sliders';
  view = ControlBrowserCapabilityView;
  cardViews = {
    powerOff: PowerOffCardView
  };

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
    this.updateCards();
    this.listenTo(this.controls(), 'change update reset', () => this.updateCards());
  }

  pathName() {
    return this.has('path') && _.last(this.get('path'));
  }

  controls() {
    return window.app.controls;
  }

  scenes() {
    return window.app.scenes;
  }

  hasHome() {
    return this.stationConfig().hasOwnProperty('homePath')
  }

  pathHasSensors() {
    return this.controls().any((control) => {
      return control.getMembership(this.get('path')) != null &&
        control.get('context') === 'sensors' &&
        control.get('valid');
      });
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

  controlsForPowerOffCard() {
    return this.controls().filter((control) => {
      return control.get('valid') && control.isActive() &&
        control.hasCommand('turnOff');
    });
  }

  updateCards() {
    const currentCard = this.cardWhere({type: 'powerOff'});
    if(this.controlsForPowerOffCard().length > 0) {
      if(currentCard == null) this.addCard({
        type: 'powerOff',
        priority: 'medium'
      });
    } else {
      this.removeCardsWhere({type: 'powerOff'});
    }
  }
}
