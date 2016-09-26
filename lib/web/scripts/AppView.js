
const Marionette = require('backbone.marionette');

module.exports = class AppView extends Marionette.View {
  template = Templates['app'];

  className() {
    return `app display-${this.getOption('display')}`;
  }
}
