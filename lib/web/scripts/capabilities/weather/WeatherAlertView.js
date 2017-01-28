
const Marionette = require('backbone.marionette');

module.exports = class WeatherAlertView extends Marionette.View {
  template = Templates['capabilities/weather/alert'];

  className() { return 'weather-alert-detail'; }
  serializeData() { return this.model; }
}
