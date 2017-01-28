
const Marionette = require('backbone.marionette');

module.exports = class DailyForecastView extends Marionette.View {
  template = Templates['capabilities/weather/daily-forecast'];

  className() { return 'daily-forecast'; }

  serializeData() {
    return {
      days: this.model.dailyForecast()
    };
  }
}
