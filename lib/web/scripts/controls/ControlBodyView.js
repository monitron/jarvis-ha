
const Marionette = require('backbone.marionette');

module.exports = class ControlBodyView extends Marionette.View {
  modelEvents() {
    return {
      'change:state': 'onStateChange',
      'task:some':    'renderClasses',
      'task:none':    'renderClasses'
    };
  }

  className() {
    const classes = ['control'];
    if(this.model.isBusy()) classes.push('busy');
    return classes.join(' ');
  }

  renderClasses() {
    this.$el.attr('class', this.className());
  }

  // Override me to do something more subtle
  onStateChange() {
    this.render();
  }
}
