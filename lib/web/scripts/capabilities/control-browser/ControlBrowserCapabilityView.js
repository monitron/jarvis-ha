
const Marionette = require('backbone.marionette');
const ControlContainersView = require('./ControlContainersView.js');

module.exports = class ControlBrowserCapabilityView extends Marionette.View {
  template = Templates['capabilities/control-browser/control-browser'];

  className() { return 'control-browser'; }

  modelEvents() {
    return {
      'change:path': 'render'
    };
  }

  regions() {
    return {
      controls: '.controls'
    };
  }

  serializeData() {
    return {
      name: this.model.pathName()
    };
  }

  onRender() {
    const controlsView = new ControlContainersView({
      collection: this.model.controls(),
      path: this.model.get('path')
    });
    this.showChildView('controls', controlsView);
  }
}
