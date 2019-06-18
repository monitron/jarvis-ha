
const Marionette = require('backbone.marionette');
const MeterValuesView = require('./MeterValuesView.js');

module.exports = class EnergyMetersView extends Marionette.View {
  template = Templates['capabilities/energy/meters'];
  className() { return 'energy-meters'; }

  regions() {
    return {
      metersByPeriod: '.metersByPeriod'
    };
  }

  modelEvents() {
    return {change: 'render'};
  }

  onRender() {
    const metersView = new Marionette.CollectionView({
      collection: this.model.metersByPeriod(),
      childView:  MeterValuesView
    });
    this.showChildView('metersByPeriod', metersView);
  }
}
