
const d3 = require('d3');
const [Capability] = require('../../Capability.js');
const WeatherCapabilityView = require('./WeatherCapabilityView.js');
const util = require('../../util.coffee');

module.exports = class WeatherCapability extends Capability {
  name = 'Weather';
  icon = 'sun-o';
  view = WeatherCapabilityView;

  formatTemp(temp) {
    if(this.get('temperatureUnits') === 'f') temp = util.tempToFahrenheit(temp);
    return d3.format(`.${this.get('temperaturePrecision')}f`)(temp);
  }

  formatHumidity(hum) {
    return d3.format(`.${this.get('humidityPrecision')}f`)(hum);
  }

  cameraUrl() {
    if(this.has('cameraUrl')) {
      const rand = Math.floor(Math.random() * 1000000);
      return `${this.get('cameraUrl')}?rand=${rand}`;
    } else {
      return undefined;
    }
  }
}
