
const Marionette = require('backbone.marionette');
const util = require('../../util.coffee');

module.exports = class WeatherCapabilityIdleView extends Marionette.View {
  template = Templates['capabilities/weather/weather-idle'];

  className() { return 'weather-idle'; }

  modelEvents() {
    return {change: 'render'};
  }

  serializeData() {
    const conditions = this.model.get('conditions');
    return {
      temperature:   this.model.formatTemp(conditions.temperature),
      humidity:      this.model.formatHumidity(conditions.humidity),
      conditionName: util.weatherConditionToName(conditions.condition),
      conditionIcon: util.weatherConditionToIcon(conditions.condition,
                                                 conditions.isDay)
    };
  }
}
