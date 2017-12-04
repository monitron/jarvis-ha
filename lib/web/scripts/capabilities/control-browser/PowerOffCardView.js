
const Marionette = require('backbone.marionette');

module.exports = class PowerOffCardView extends Marionette.View {
  template = Templates['capabilities/control-browser/power-off-card'];

  serializeData() {
    const controls = this.model.capability().controlsForPowerOffCard();
    return {
      count:    controls.length,
      plural:   controls.length != 1,
      controls: controls.map((control) => {
        return {
          name: control.get('name')
        };
      })
    };
  }
}
