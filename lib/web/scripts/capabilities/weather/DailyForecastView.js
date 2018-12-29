
const Marionette = require('backbone.marionette');

module.exports = class DailyForecastView extends Marionette.View {
  template = Templates['capabilities/weather/daily-forecast'];

  className() { return 'daily-forecast'; }

  serializeData() {
    var days = this.model.dailyForecast();
    if(this.options.maxDays != null)
      days = days.slice(0, this.options.maxDays);
    return {
      narrative: this.model.rawCondition('dailyForecastNarrative'),
      days: days
    };
  }
}
