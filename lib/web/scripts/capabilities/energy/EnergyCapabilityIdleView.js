
const Marionette = require('backbone.marionette');
const MeterValuesView = require('./MeterValuesView.js');

module.exports = class EnergyCapabilityIdleView extends Marionette.View {
  template = Templates['capabilities/energy/energy-idle'];

  className() { return 'energy-idle'; }

  regions() {
    return {
      meters: '.meters'
    };
  }

  modelEvents() {
    return {change: 'render'};
  }

  onRender() {
    const period = this.model.get('idlePeriod');
    const meter = this.model.metersByPeriod().get(period);
    if(meter != null) {
      const metersView = new MeterValuesView({
        model: meter
      });
      this.showChildView('meters', metersView);
    }
  }
}
