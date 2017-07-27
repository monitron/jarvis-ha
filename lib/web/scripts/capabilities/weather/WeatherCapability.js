
const _ = require('underscore');
const d3 = require('d3');
const moment = require('moment');
const [Capability] = require('../../Capability.js');
const WeatherCapabilityView = require('./WeatherCapabilityView.js');
const DailyIdleView = require('./DailyIdleView.js');
const HourlyIdleView = require('./HourlyIdleView.js');
const ConditionsIdleView = require('./ConditionsIdleView.js');
const util = require('../../util.coffee');

module.exports = class WeatherCapability extends Capability {
  name = 'Weather';
  icon = 'sun-o';
  view = WeatherCapabilityView;
  idleViews = [ConditionsIdleView, HourlyIdleView, DailyIdleView];

  defaults() {
    return {
      currentPage: 'current'
    };
  }

  convertTemp(temp) {
    if(this.get('temperatureUnits') === 'f') {
      return util.tempToFahrenheit(temp);
    } else {
      return temp;
    }
  }

  formatTemp(temp) {
    return d3.format(`.${this.get('temperaturePrecision')}f`)(
      this.convertTemp(temp));
  }

  formatHumidity(hum) {
    return d3.format(`.${this.get('humidityPrecision')}f`)(hum);
  }

  convertSpeed(speed) {
    if(this.get('speedUnits') === 'mph') {
      return util.speedToMPH(speed);
    } else {
      return speed;
    }
  }

  formatSpeed(speed) {
    return d3.format(`.0f`)(this.convertSpeed(speed));
  }

  formatPressure(pres) {
    if(this.get('pressureUnits') === 'in') pres = util.pressureToInHg(pres);
    return d3.format(`.${this.get('pressurePrecision')}f`)(pres);
  }

  pages() {
    const conditions = this.get('state').conditions;
    const pages = [{id: 'current', name: 'Now'}];
    if(conditions.forecastHours != null)
      pages.push({id: 'hourly', name: 'Hourly'});
    if(conditions.forecastDays != null)
      pages.push({id: 'daily', name: 'Daily'});
    _.findWhere(pages, {id: this.get('currentPage')}).active = true;
    return pages;
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
        dayOfWeek:       date.format('ddd'),
        windSpeed:       this.formatSpeed(day.windSpeed)
      };
    });
  }

  hourlyForecast() {
    const hours = this.get('state').conditions.forecastHours;
    if(hours == null) return null;
    return hours.map((hour) => {
      return {
        hour:              moment({h: hour.hour}).format('ha'),
        conditionIcon:     util.weatherConditionToIcon(hour.condition),
        temperature:       this.convertTemp(hour.temperature),
        temperatureString: this.formatTemp(hour.temperature),
        nonzeroPop:        hour.pop > 0,
        pop:               hour.pop,
        humidity:          hour.humidity,
        humidityString:    this.formatHumidity(hour.humidity),
        windSpeedString:   this.formatSpeed(hour.windSpeed)
      };
    });
  }

  detailedCurrentConditions() {
    const conds = this.get('state').conditions;
    const details = []
    if(conds.apparentTemperature != null)
      details.push({
        name:  "Feels Like",
        value: this.formatTemp(conds.apparentTemperature) + '&deg;'});
    if(conds.humidity != null)
      details.push({
        name:  "Humidity",
        value: this.formatHumidity(conds.humidity) + '%'});
    if(conds.dewpoint != null)
      details.push({
        name:  "Dewpoint",
        value: this.formatTemp(conds.dewpoint) + '&deg;',
        sub: util.describeDewpoint(conds.dewpoint)});
    if(conds.ultravioletIndex != null)
      details.push({
        name:  "UV Index",
        value: conds.ultravioletIndex,
        sub: util.describeUvIndex(conds.ultravioletIndex)});
    if(conds.windSpeed != null) {
      const windSpeed = this.formatSpeed(conds.windSpeed);
      const windDetails = {name: 'Wind'};
      if(conds.windSpeed > 0) {
        windDetails.value = `${windSpeed} ${this.get('speedUnits')}`;
        if(conds.windDirection != null) windDetails.sub = 'From ' +
          util.angleToCardinalDirection(conds.windDirection);
      } else {
        windDetails.value = 'Calm';
      }
      details.push(windDetails);
    }
    if(conds.barometricPressure != null) {
      const pressure = this.formatPressure(conds.barometricPressure);
      details.push({
        name:  "Pressure",
        value: `${pressure} ${this.get('pressureUnits')}`})
    }
    return details;
  }

  alerts() {
    const alerts = this.get('state').conditions.alerts;
    if(alerts == null) return [];
    return alerts.map((alert) => {
      return {
        id: alert.digest,
        level: (alert.significance == 'warning' ? 'high' :
                (alert.significance == 'watch' ? 'medium' : 'low')),
        description: alert.description,
        start: moment(alert.start).calendar(),
        end: moment(alert.end).calendar(),
        message: alert.message.replace(/\n/g, '<br>')
      };
    });
  }

  cameraUrl() {
    const conditions = this.get('state').conditions || {};
    if(conditions.imageLocation != null) {
      if(this.get('cameraRefreshInterval') != null) {
        const rand = Math.floor(Math.random() * 1000000);
        return `${conditions.imageLocation}?rand=${rand}`;
      } else {
        return conditions.imageLocation;
      }
    } else {
      return undefined;
    }
  }
}
