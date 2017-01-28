
const _ = require('underscore');
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

  alertTimeFormat = "dddd MMMM Do h:mm a";

  defaults() {
    return {
      currentPage: 'current'
    };
  }

  formatTemp(temp) {
    if(this.get('temperatureUnits') === 'f') temp = util.tempToFahrenheit(temp);
    return d3.format(`.${this.get('temperaturePrecision')}f`)(temp);
  }

  formatHumidity(hum) {
    return d3.format(`.${this.get('humidityPrecision')}f`)(hum);
  }

  formatSpeed(speed) {
    if(this.get('speedUnits') === 'mph') speed = util.speedToMPH(speed);
    return d3.format(`.0f`)(speed);
  }

  formatPressure(pres) {
    if(this.get('pressureUnits') === 'in') pres = util.pressureToInHg(pres);
    return d3.format(`.${this.get('pressurePrecision')}f`)(pres);
  }

  pages() {
    const conditions = this.get('state').conditions;
    const pages = [{id: 'current', name: 'Now'}];
//    if(conditions.forecastHours != null)
//      pages.push({id: 'hourly', name: 'Hourly'});
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
        dayOfWeek:       date.format('ddd')
      }
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
        value: this.formatTemp(conds.dewpoint) + '&deg;'});
    if(conds.ultravioletIndex != null)
      details.push({
        name:  "UV Index",
        value: conds.ultravioletIndex});
    if(conds.windSpeed != null) {
      const windSpeed = this.formatSpeed(conds.windSpeed);
      var wind = `${windSpeed} ${this.get('speedUnits')}`;
      if(conds.windDirection != null) {
        const windDir = util.angleToCardinalDirection(conds.windDirection);
        wind = wind + ` from ${windDir}`;
      }
      details.push({name: 'Wind', value: wind});
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
        start: moment(alert.start).format(this.alertTimeFormat),
        end: moment(alert.end).format(this.alertTimeFormat),
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
