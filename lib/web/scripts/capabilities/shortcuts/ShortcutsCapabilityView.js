const Marionette = require('backbone.marionette');

module.exports = class ShortcutsCapabilityView extends Marionette.View {
  template = Templates['capabilities/shortcuts/shortcuts'];
}
