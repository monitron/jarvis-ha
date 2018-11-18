
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
    this.$el.addClass('busy');
    this.model.activate()
      .fail(() => {
        this.$el.removeClass('busy');
        this.$el.addClass('failed');
        setTimeout(() => this.$el.removeClass('failed'), 2000);
      })
      .then(() => this.$el.removeClass('busy'));
  }
}
