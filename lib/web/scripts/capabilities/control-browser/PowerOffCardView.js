
const Marionette = require('backbone.marionette');

module.exports = class PowerOffCardView extends Marionette.View {
  template = Templates['capabilities/control-browser/power-off-card'];
  overflowAt = 5;

  ui() {
    return {
      controlName: '.name',
      offButton:   '.off-button',
      disclosure:  '.overflow-disclosure'
    };
  }

  events() {
    return {
      'click @ui.offButton':   'onClickOffButton',
      'click @ui.controlName': 'onClickControlName',
      'click @ui.disclosure':  'onClickDisclosure'
    };
  }

  initialize() {
    this.listenTo(window.app.controls, 'change task:some task:none',
                  () => {if(this.model.collection != null) this.render()});
  }

  serializeData() {
    const controls = this.model.capability().controlsForPowerOffCard();
    const overflowing = controls.length > this.overflowAt;
    return {
      count:       controls.length,
      plural:      controls.length != 1,
      overflowing: overflowing,
      controls:    controls.map((control, index) => {
        return {
          id:   control.id,
          name: control.get('name'),
          busy: control.isBusy(),
          dangerous: control.get('dangerous'),
          overflow: overflowing && index > (this.overflowAt - 2)
        };
      })
    };
  }

  onClickOffButton(event) {
    const id = $(event.target).closest('.control').data('id');
    window.app.controls.get(id).sendCommand('turnOff');
  }

  onClickControlName(event) {
    const id = $(event.target).closest('.control').data('id');
    window.app.visitControl(id);
  }

  onClickDisclosure(event) {
    this.$el.addClass('overflow-disclosed');
  }
}
