
const Marionette = require('backbone.marionette');

module.exports = class SceneView extends Marionette.View {
  template = Templates['capabilities/control-browser/scene'];

  className() { return 'scene'; }

  events() { return {click: 'onClick'}; }

  serializeData() {
    const membership = this.getOption('membership');
    return {
      name: membership.name || this.model.get('name'),
      icon: membership.icon || this.model.get('icon') || 'bolt'
    }
  }

  onClick() {
    this.model.activate();
  }
}
