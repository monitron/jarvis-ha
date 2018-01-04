
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

  visitControl(id) {
    const control = this.controls().get(id);
    const path = control.getDefaultMembershipPath(['location']);
    if(path) this.set({path: path, 'highlight-control': id});
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

  shortcuts() {
    const station = this.stationConfig();
    if(station && station.homePath != null) {
      const scenes = this.scenes().filter((s) => {
        return s.getMembership(station.homePath) != null && s.get('valid')});
      const cuts = _.map(scenes, (scene) => {
        return {
          id: `scene-${scene.id}`,
          icon: scene.get('icon'),
          title: scene.get('name'),
          onClick: () => scene.activate()
        };
      });
      cuts.push({
        id: 'visit',
        icon: 'sliders',
        title: 'All Controls Here',
        important: true,
        link: true,
        onClick: () => { this.set('path', station.homePath); this.visit(); }
      });
      return [{
        id: 'controls-here',
        priority: 10,
        title: 'Controls Here',
        icon: 'map-marker',
        contents: cuts
      }];
    } else {
      return [];
    }
  }
}
