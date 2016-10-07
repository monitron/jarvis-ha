
const Marionette = require('backbone.marionette');
const CapabilityIconsView = require('./CapabilityIconsView.js');

module.exports = class DesktopNavView extends Marionette.View {
  template = Templates['nav/desktop'];

  regions() {
    return {
      capabilities: '.capabilities'
    };
  }

  onRender() {
    const capsView = new CapabilityIconsView({
      collection: this.model.capabilities,
      model: this.model
    });
    this.showChildView('capabilities', capsView);
  }
}
