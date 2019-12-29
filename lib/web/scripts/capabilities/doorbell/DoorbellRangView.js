const Marionette = require('backbone.marionette');

module.exports = class DoorbellRangView extends Marionette.View {
  template = Templates['capabilities/doorbell/rang'];

  regions() {
    return {
      camera: '.camera',
      control: '.door-control-container'
    };
  }

  className() { return 'doorbell-rang'; }

  initialize() {
    // Don't persist if the app goes idle; likely we're no longer relevant
    this.listenTo(window.app, 'idle:enter', () => this.destroy());
  }

  onRender() {
    const cfg = this.model.getDoorConfig(this.options.doorId);
    const camView = window.app.capabilities.get('cameras').
          createLiveView(cfg.camera);
    this.showChildView('camera', camView);
    const controlView = window.app.capabilities.get('controlBrowser').
          createControlContainerView(cfg.control, {headerless: true});
    this.showChildView('control', controlView);
  }
}
