
const Marionette = require('backbone.marionette');

module.exports = class ActivateSceneView extends Marionette.View {
  template = Templates['activate-scene'];

  initialize() {
    this.options.promise.always(() => { this.render(); });
  }

  className() {
    return 'activate-scene';
  }

  serializeData() {
    window.app.prom = this.options.promise;
    return {
      name: this.model.get('name'),
      icon: this.model.get('icon'),
      done: this.options.promise.state() == 'resolved',
      failed: this.options.promise.state() == 'rejected'
    };
  }
}
