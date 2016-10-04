
const Marionette = require('backbone.marionette');
const ControlContainersView = require('./ControlContainersView.js');

module.exports = class ControlBrowserCapabilityView extends Marionette.View {
  template = Templates['capabilities/control-browser/control-browser'];

  className() { return 'control-browser'; }

  modelEvents() {
    return {'change:path': 'render'};
  }

  regions() {
    return {controls: '.controls'};
  }

  ui() {
    return {pickLocation: '.pick-location-button'};
  }

  events() {
    return {'click @ui.pickLocation': 'onClickPickLocation'};
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

  onClickPickLocation() {
    const callback = (path) => this.model.set('path', path);
    window.app.pickLocation(callback, this.model.get('path'));
  }
}
