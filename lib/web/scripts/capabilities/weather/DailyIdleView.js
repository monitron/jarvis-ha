
const Marionette = require('backbone.marionette');
const util = require('../../util.coffee');
const DailyForecastView = require('./DailyForecastView.js');

module.exports = class DailyIdleView extends Marionette.View {
  template = Templates['capabilities/weather/daily-idle'];

  className() { return 'weather-idle-daily'; }

  regions() {
    return {
      forecast: '.forecast'
    };
  }

  modelEvents() {
    return {change: 'render'};
  }

  onRender() {
    const forecastView = new DailyForecastView({
      model: this.model,
      maxDays: 3
    });
    this.showChildView('forecast', forecastView);
  }
}
