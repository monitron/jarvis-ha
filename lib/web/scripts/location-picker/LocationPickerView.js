
const _ = require('underscore');
const Marionette = require('backbone.marionette');
const LocationPickerListView = require('./LocationPickerListView.js');

module.exports = class LocationPickerView extends Marionette.View {
  template = Templates['location-picker/location-picker'];

  className() {
    return 'location-picker';
  }

  regions() {
    return {
      rooms: '.rooms'
    };
  }

  ui() {
    return {
      floor: '.floor'
    };
  }

  events() {
    return {
      'click @ui.floor': 'onFloorClick'
    };
  }

  initialize() {
    this.basePath = ['location'];
    const current = this.getOption('current');
    if(current != null) {
      this.floor = current[1];
      this.room = current[2];
    }
    this.listenTo(window.app.controls, 'change',
                 _.debounce(() => this.render(), 100));
  }

  serializeData() {
    return {
      floors: this.buildFloors()
    };
  }

  onRender() {
    this.showRooms();
  }

  rooms() {
    const path = this.floorPath();
    const rooms = window.app.controls.findSubpathsOfPath(path);
    return rooms.map(function(room) {
      return {
        name: room,
        active: window.app.controls.pathContainsActiveControls(
          [...path, room])
      };
    });
  }

  showRooms() {
    if(this.floor != null) {
      const listView = new LocationPickerListView({
        rooms: this.rooms(), current: this.room});
      this.listenTo(listView, 'select',
                    (room) => this.commit([...this.floorPath(), room]));
      this.showChildView('rooms', listView);
    }
  }

  onFloorClick(event) {
    this.floor = $(event.target).closest('.floor').data('floor');
    const path = this.floorPath();
    if(this.rooms().length) {
      this.render();
    } else {
      this.commit(path); // This floor is a leaf node; select it
    }
  }

  floorPath() {
    return [...this.basePath, this.floor];
  }

  buildFloors() {
    const floors = window.app.controls.findSubpathsOfPath(this.basePath);
    return floors.map(function(floor) {
      return {
        name: floor,
        selected: this.floor === floor,
        active: window.app.controls.pathContainsActiveControls(
          [...this.basePath, floor])
      }
    }.bind(this));
  }

  commit(path) {
    this.getOption('callback')(path);
    this.destroy();
  }
}
