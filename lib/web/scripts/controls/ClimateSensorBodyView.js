
const d3 = require('d3');
const ControlBodyView = require('./ControlBodyView.js');
const {tempToFahrenheit} = require('../util.coffee');

module.exports = class ClimateSensorBodyView extends ControlBodyView {
  template = Templates['controls/climateSensor'];

  serializeData() {
    const state = this.model.get('state');
    const params = this.model.get('parameters');
    const data = {};
    if(state.temperature != null) {
      var temp = state.temperature;
      if(params.temperatureUnits === 'f') temp = tempToFahrenheit(temp);
      data.temperature = d3.format(`.${params.temperaturePrecision}f`)(temp);
    }
    if(state.humidity != null) {
      data.humidity = d3.format(`.${params.humidityPrecision}f`)(
        state.humidity);
    }
    return data;
  }
}
