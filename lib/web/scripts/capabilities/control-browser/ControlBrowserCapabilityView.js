
const Marionette = require('backbone.marionette');
const ControlContainersView = require('./ControlContainersView.js');
const SensorsView = require('./SensorsView.js');
const ScenesView = require('./ScenesView.js');

module.exports = class ControlBrowserCapabilityView extends Marionette.View {
  template = Templates['capabilities/control-browser/control-browser'];

  className() {
    const classes = ['control-browser'];
    if(this.model.pathHasSensors()) classes.push('with-sensors');
    return classes.join(' ');
  }

  modelEvents() {
    return {
      'change:path': 'render',
      'change:highlight-control': 'highlightControl'
    };
  }

  regions() {
    return {
      controls: '.controls',
      sensors:  '.sensors',
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
    this.$el.attr('class', this.className());
    if(!this.model.has('path')) this.pickLocation();
    const controlsView = new ControlContainersView({
      collection: this.model.controls(),
      path: this.model.get('path')
    });
    this.showChildView('controls', controlsView);
    const sensorsView = new SensorsView({
      collection: this.model.controls(),
      path: this.model.get('path')
    });
    this.showChildView('sensors', sensorsView);
    const scenesView = new ScenesView({
      collection: this.model.scenes(),
      path: this.model.get('path')
    });
    this.showChildView('scenes', scenesView);
    if(this.model.has('highlight-control')) this.highlightControl();
  }
  
  highlightControl() {
    this.getChildView('controls').scrollTo(this.model.get('highlight-control'));
    this.model.unset('highlight-control');
  }

  onClickGoHome() {
    this.model.goHome();
  }

  pickLocation() {
    const callback = (path) => this.model.set('path', path);
    window.app.pickLocation(callback, this.model.get('path'));
  }
}
