const _ = require('underscore');
const Marionette = require('backbone.marionette');
const TemperatureChartView = require('./TemperatureChartView')
const POPChartView = require('./POPChartView')

module.exports = class DailyForecastView extends Marionette.View {
  template = Templates['capabilities/weather/hourly-forecast'];

  className() { return 'hourly-forecast'; }

  regions() {
    return {
      temperatureChart: '.temp-chart-container',
      popChart:         '.pop-chart-container'
    };
  }

  initialize() {
    this.forecast = this.model.hourlyForecast();
    if(this.options.maxHours != null)
      this.forecast = this.forecast.slice(0, this.options.maxHours);
  }

  serializeData() {
    return {
      narrative: this.model.rawCondition('hourlyForecastNarrative'),
      hours: this.forecast
    };
  }
  
  onRender() {
    const tcview = new TemperatureChartView({
      model: _.pluck(this.forecast, 'temperature')
    });
    const pcview = new POPChartView({
      model: _.pluck(this.forecast, 'pop')
    });
    this.showChildView('temperatureChart', tcview);
    this.showChildView('popChart', pcview);
  }
}
