const Marionette = require('backbone.marionette');

module.exports = class HomeCardView extends Marionette.View {
  template = Templates['capabilities/home/card'];

  className() {
    return 'home-card';
  }

  ui() {
    return {
      capability: '.capability'
    };
  }

  events() {
    return {
      'click @ui.capability': 'onClickCapability'
    };
  }

  regions() { return {body: '.body'}; }

  serializeData() {
    const capability = this.model.capability();
    return {
      icon: capability.icon,
      name: capability.name
    };
  }

  onRender() {
    this.showChildView('body', this.model.bodyView());
  }

  onClickCapability() {
    this.model.capability().visit();
  }
}
