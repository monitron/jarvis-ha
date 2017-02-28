const _ = require('underscore');
const Marionette = require('backbone.marionette');
const TemperatureChartView = require('./TemperatureChartView')

module.exports = class DailyForecastView extends Marionette.View {
  template = Templates['capabilities/weather/hourly-forecast'];

  className() { return 'hourly-forecast'; }

  regions() {
    return {
      temperatureChart: '.chart-container'
    };
  }

  serializeData() {
    var hours = this.model.hourlyForecast();
    if(this.options.maxHours != null)
      hours = hours.slice(0, this.options.maxHours);
    return {hours: hours};
  }
  
  onRender() {
    const cview = new TemperatureChartView({
      model: _.pluck(this.model.hourlyForecast(), 'temperature')
    });
    this.showChildView('temperatureChart', cview);
  }
}
