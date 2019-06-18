
const Marionette = require('backbone.marionette');

module.exports = class ConsumersChartView extends Marionette.View {
  template = Templates['capabilities/energy/consumers-chart'];
  className() { return 'consumers-chart'; }

  serializeData() {
    return {
      consumers: this.model.consumers(),
    };
  }
}
