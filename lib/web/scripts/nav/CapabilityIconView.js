
const Marionette = require('backbone.marionette');

module.exports = class CapabilityIconView extends Marionette.View {
  className() { return 'capability'; }
  template = Templates['nav/capability-icon'];

  serializeData() {
    return {
      name: this.model.name,
      icon: this.model.icon
    };
  }
}
