
const Marionette = require('backbone.marionette');
const util = require('../../util.coffee');
const HourlyForecastView = require('./HourlyForecastView.js');

module.exports = class DailyIdleView extends Marionette.View {
  template = Templates['capabilities/weather/hourly-idle'];

  className() { return 'weather-idle-hourly'; }

  regions() {
    return {
      forecast: '.forecast'
    };
  }

  modelEvents() {
    return {change: 'render'};
  }

  onRender() {
    const forecastView = new HourlyForecastView({
      model: this.model,
      maxHours: 4
    });
    this.showChildView('forecast', forecastView);
  }
}
