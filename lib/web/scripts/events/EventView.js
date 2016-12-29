
const Marionette = require('backbone.marionette');

module.exports = class EventView extends Marionette.View {
  template = Templates['event'];

  className() {
    return `event ${this.model.get('importance')}-importance`;
  }

  serializeData() {
    const cap = window.app.capabilities.get(this.model.get('capability'));
    return {
      capabilityName: cap.name,
      capabilityIcon: cap.icon,
      title: this.model.get('title')
    }
  }
}
