
const Marionette = require('backbone.marionette');
const ControlContainersView = require('./ControlContainersView.js');
const ScenesView = require('./ScenesView.js');

module.exports = class ControlBrowserCapabilityView extends Marionette.View {
  template = Templates['capabilities/control-browser/control-browser'];

  className() { return 'control-browser'; }

  modelEvents() {
    return {'change:path': 'render'};
  }

  regions() {
    return {
      controls: '.controls',
      scenes:   '.scenes'
    };
  }

  ui() {
    return {
      pickLocation: '.pick-location-button',
      goHome:       '.go-home-button'
    };
  }

  events() {
    return {
      'click @ui.pickLocation': 'pickLocation',
      'click @ui.goHome':       'onClickGoHome'
    };
  }

  serializeData() {
    return {
      name:     this.model.pathName(),
      hasHome:  this.model.hasHome(),
      isAtHome: this.model.isAtHome()
    };
  }

  onRender() {
    if(!this.model.has('path')) this.pickLocation();
    const controlsView = new ControlContainersView({
      collection: this.model.controls(),
      path: this.model.get('path')
    });
    this.showChildView('controls', controlsView);
    const scenesView = new ScenesView({
      collection: this.model.scenes(),
      path: this.model.get('path')
    });
    this.showChildView('scenes', scenesView);
  }

  onClickGoHome() {
    this.model.goHome();
  }

  pickLocation() {
    const callback = (path) => this.model.set('path', path);
    window.app.pickLocation(callback, this.model.get('path'));
  }
}
