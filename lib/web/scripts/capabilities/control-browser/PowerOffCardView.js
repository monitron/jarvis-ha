
const Marionette = require('backbone.marionette');

module.exports = class PowerOffCardView extends Marionette.View {
  template = Templates['capabilities/control-browser/power-off-card'];

  ui() {
    return {
      controlName: '.name',
      offButton:   '.off-button'
    };
  }

  events() {
    return {
      'click @ui.offButton':   'onClickOffButton',
      'click @ui.controlName': 'onClickControlName',
    };
  }

  initialize() {
    this.listenTo(window.app.controls, 'change task:some task:none',
                  () => this.render());
  }

  serializeData() {
    const controls = this.model.capability().controlsForPowerOffCard();
    return {
      count:    controls.length,
      plural:   controls.length != 1,
      controls: controls.map((control) => {
        return {
          id:   control.id,
          name: control.get('name'),
          busy: control.isBusy()
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
}
