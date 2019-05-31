
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
    // When entering idle, ensure next user sees home room
    this.listenTo(window.app, 'idle:enter', () => this.goHome());
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
    if(this.hasHome()) this.set('path', this.stationConfig()['homePath']);
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
    const shortcuts = [];
    if(station) {
      if(station.favoriteRooms != null) {
        shortcuts.push({
          id: 'favorite-rooms',
          priority: 7,
          title: 'Favorite Rooms',
          icon: 'heart',
          contents: station.favoriteRooms.map((room) => {
            return {
              id: `fav-room-${room.join('-')}`,
              title: _.last(room),
              icon: 'map',
              link: true,
              onClick: () => { this.set('path', room); this.visit(); }
            }
          })
        });
      }
      if(station.favoriteScenes != null) {
        const favSceneItems = _.chain(station.favoriteScenes)
              .map(sceneid => this.scenes().get(sceneid))
              .filter(scene => scene != null && scene.get('valid'))
              .map(scene => {
                return {
                  id: `fav-scene-${scene.id}`,
                  title: scene.get('name'),
                  icon: scene.get('icon'),
                  onClick: () => scene.activate()
                }
              })
              .value();
        if(favSceneItems.length > 0) {
          console.log(favSceneItems);
          shortcuts.push({
            id: 'favorite-scenes',
            priority: 8,
            title: 'Favorite Scenes',
            icon: 'heart',
            contents: favSceneItems
          });
        }
      }
      if(station.homePath != null) {
        const scenes = this.scenes().filter((s) => {
          return s.getMembership(station.homePath) != null && s.get('valid')});
        const homeCuts = _.map(scenes, (scene) => {
          return {
            id: `scene-${scene.id}`,
            icon: scene.get('icon'),
            title: scene.get('name'),
            onClick: () => scene.activate()
          };
        });
        homeCuts.push({
          id: 'visit',
          icon: 'sliders',
          title: 'All Controls Here',
          important: true,
          link: true,
          onClick: () => { this.set('path', station.homePath); this.visit(); }
        });
        shortcuts.push({
          id: 'controls-here',
          priority: 10,
          title: 'Controls Here',
          icon: 'map-marker',
          contents: homeCuts
        });
      }
    }
    return shortcuts;
  }
}
