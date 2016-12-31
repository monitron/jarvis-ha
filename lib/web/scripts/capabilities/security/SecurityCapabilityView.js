
const Marionette = require('backbone.marionette');

module.exports = class SecurityCapabilityView extends Marionette.View {
  template = Templates['capabilities/security/security'];

  className() { return 'security-capability'; }

  modelEvents() {
    return {change: 'render'};
  }

  ui() {
    return {
      mode: '.modes li:not(.current)'
    };
  }

  events() {
    return {
      'click @ui.mode': 'onModeClick'
    };
  }

  serializeData() {
    return {
      modes: this.model.modes(),
      status: this.model.ruleStatus()
    };
  }

  onModeClick(ev) {
    const id = $(ev.target).closest('li').data('id');
    this.model.sendCommand('setMode', {mode: id});
  }
}
