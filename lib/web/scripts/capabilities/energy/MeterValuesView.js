
const Marionette = require('backbone.marionette');

module.exports = class MeterValuesView extends Marionette.View {
  template = Templates['capabilities/energy/meterValues'];
  className() { return 'energy-meter-values'; }

  serializeData() {
    return {
      name:    this.model.get('name'),
      meters:  this.model.get('meters'),
      offsets: this.model.get('offsets')
    };
  }
}
