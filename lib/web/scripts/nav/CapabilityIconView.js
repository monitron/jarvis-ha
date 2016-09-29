
const Marionette = require('backbone.marionette');

module.exports = class CapabilityIconView extends Marionette.View {
  template = Templates['nav/capability-icon'];

  className() {
    return `capability${this.getOption('selected') ? ' selected' : ''}`;
  }

  serializeData() {
    return {
      name: this.model.name,
      icon: this.model.icon,
      url:  `#capability/${this.model.id}`
    };
  }
}
