
const Marionette = require('backbone.marionette');
const util = require('../../util.coffee');

module.exports = class ConditionsIdleView extends Marionette.View {
  template = Templates['capabilities/weather/conditions-idle'];

  className() { return 'weather-idle-conditions'; }

  modelEvents() {
    return {change: 'render'};
  }

  serializeData() {
    const conditions = this.model.get('state').conditions;
    return {
      temperature:   this.model.formatTemp(conditions.temperature),
      humidity:      this.model.formatHumidity(conditions.humidity),
      windSpeed:     this.model.formatSpeed(conditions.windSpeed),
      windUnits:     this.model.get('speedUnits'),
      conditionName: util.weatherConditionToName(conditions.condition),
      conditionIcon: util.weatherConditionToIcon(conditions.condition,
                                                 conditions.isDay)
    };
  }
}
