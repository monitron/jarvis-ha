
const Marionette = require('backbone.marionette');
const SensorDisparityView = require('./SensorDisparityView');

module.exports = class ComfortCapabilityView extends Marionette.View {
  template = Templates['capabilities/comfort/comfort'];
  className() { return 'comfort-capability'; }

  regions() {
    return {
      temperatureDisparity: '.temperature-disparity'
    };
  }

  onRender() {
    const sdview = new SensorDisparityView({
      model: this.model.sensorDisparities('temperatureSensor')
    });
    this.showChildView('temperatureDisparity', sdview);
  }
}
