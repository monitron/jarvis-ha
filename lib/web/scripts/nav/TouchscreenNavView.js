
const Marionette = require('backbone.marionette');
const CapabilityIconView = require('./CapabilityIconView.js');

module.exports = class TouchscreenNavView extends Marionette.View {
  template = Templates['nav/touchscreen'];

  regions() {
    return {
      capabilities: '.capabilities'
    };
  }

  onRender() {
    const capsView = new Marionette.CollectionView({
      childView: CapabilityIconView,
      collection: this.model.capabilities
    });
    this.showChildView('capabilities', capsView);
  }
}
