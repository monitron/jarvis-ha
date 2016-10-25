
const Marionette = require('backbone.marionette');
const util = require('../../util.coffee');

module.exports = class WeatherCapabilityView extends Marionette.View {
  template = Templates['capabilities/weather/weather'];

  className() { return 'weather-capability'; }
  
  initialize() {
    if(this.model.has('cameraUrl')) {
      this.cameraInterval = setInterval(this.render.bind(this), 1000 * 60 * 5);
    }
  }
  
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
                                                 conditions.isDay),
      camera:        this.model.cameraUrl()
    };
  }

  onDestroy() {
    if(this.cameraInterval != null) clearInterval(this.cameraInterval);
  }
}
