
const Marionette = require('backbone.marionette');

module.exports = class DebugView extends Marionette.View {
  template = Templates['debug'];

  className() { return 'debug'; }

  serializeData() {
    return {entries: this.model.logBuffer};
  };
}
