
const Marionette = require('backbone.marionette');

const ConsumersChartView = require('./ConsumersChartView.js');

module.exports = class EnergyConsumersView extends Marionette.View {
  template = Templates['capabilities/energy/consumers'];
  className() { return 'energy-consumers'; }

  regions() {
    return {
      chart: '.chart'
    };
  }

  modelEvents() {
    return {change: 'render'};
  }

  onRender() {
    const chartView = new ConsumersChartView({model: this.model});
    this.showChildView('chart', chartView);
  }
}
