
const d3 = require('d3');
const moment = require('moment');
const [Capability] = require('../../Capability.js');
const WeatherCapabilityView = require('./WeatherCapabilityView.js');
const WeatherCapabilityIdleView = require('./WeatherCapabilityIdleView.js');
const util = require('../../util.coffee');

module.exports = class WeatherCapability extends Capability {
  name = 'Weather';
  icon = 'sun-o';
  view = WeatherCapabilityView;
  idleView = WeatherCapabilityIdleView;

  defaults() {
    return {
      currentForecast: 'hourly'
    };
  }

  formatTemp(temp) {
    if(this.get('temperatureUnits') === 'f') temp = util.tempToFahrenheit(temp);
    return d3.format(`.${this.get('temperaturePrecision')}f`)(temp);
  }

  formatHumidity(hum) {
    return d3.format(`.${this.get('humidityPrecision')}f`)(hum);
  }

  dailyForecast() {
    const days = this.get('state').conditions.forecastDays;
    if(days == null) return null;
    return days.map((day) => {
      const date = moment({y: day.year, M: day.month - 1, d: day.day});
      return {
        conditionIcon:   util.weatherConditionToIcon(day.condition),
        highTemperature: this.formatTemp(day.highTemperature),
        lowTemperature:  this.formatTemp(day.lowTemperature),
        pop:             day.pop,
        dayOfMonth:      day.day,
        dayOfWeek:       date.format('ddd')
      }
    });
  }

  cameraUrl() {
    const conditions = this.get('state').conditions || {};
    if(conditions.imageLocation != null) {
      const rand = Math.floor(Math.random() * 1000000);
      return `${conditions.imageLocation}?rand=${rand}`;
    } else {
      return undefined;
    }
  }
}
