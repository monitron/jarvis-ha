
const Marionette = require('backbone.marionette');
const SensorDisparityView = require('./SensorDisparityView');

module.exports = class ComfortCapabilityView extends Marionette.View {
  template = Templates['capabilities/comfort/comfort'];
  className() { return 'comfort-capability'; }
  
  modelEvents() {
    return {change: 'render'};
  }

  regions() {
    return {
      temperatureDisparity: '.temperature-disparity'
    };
  }

  serializeData() {
    const zoneState = this.model.currentZoneState();
    return {
      currentTemperature: zoneState.temperatureFormatted,
      currentHumidity: zoneState.humidityFormatted
    };
  }

  onRender() {
    const sdview = new SensorDisparityView({
      model: this.model.sensorDisparities('temperatureSensor')
    });
    this.showChildView('temperatureDisparity', sdview);
  }
}
