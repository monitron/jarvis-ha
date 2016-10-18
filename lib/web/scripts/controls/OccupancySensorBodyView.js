
const Backbone = require('backbone');
const ControlBodyView = require('./ControlBodyView.js');

module.exports = class OccupancySensorBodyView extends ControlBodyView {
  template = Templates['controls/occupancySensor'];

  serializeData() {
    const state = this.model.get('state');
    return {
      isKnown: state.occupied != null,
      isOccupied: state.occupied
    };
  }

  onStateChange() {
    this.render();
  }
}
