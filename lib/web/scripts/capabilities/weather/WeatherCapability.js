
const _ = require('underscore');
const d3 = require('d3');
const moment = require('moment');
const [Capability] = require('../../Capability.js');
const WeatherCapabilityView = require('./WeatherCapabilityView.js');
const DailyIdleView = require('./DailyIdleView.js');
const HourlyIdleView = require('./HourlyIdleView.js');
const ConditionsIdleView = require('./ConditionsIdleView.js');
const WeatherSummaryCardView = require('./WeatherSummaryCardView.js');
const WeatherAlertView = require('./WeatherAlertView.js');
const util = require('../../util.coffee');
const DailyForecastView = require('./DailyForecastView.js');
const HourlyForecastView = require('./HourlyForecastView.js');
const CurrentConditionsView = require('./CurrentConditionsView.js');

module.exports = class WeatherCapability extends Capability {
  name = 'Weather';
  icon = 'sun-o';
  view = WeatherCapabilityView;
  idleViews = [ConditionsIdleView, HourlyIdleView, DailyIdleView];
  cardViews = {
    summary: WeatherSummaryCardView
  };

  defaults() {
    return {
      page: 'current'
    };
  }

  initialize(attrs, options) {
    super.initialize(attrs, options);
    this.addCard({
      type: 'summary',
      priority: 'low'
    });
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

  formatPrecip(amt) {
    return d3.format(`.${this.get('precipitationPrecision')}f`)(
      this.convertPrecip(amt));
  }

  formatPop(pop) {
    return d3.format(`.0f`)(pop);
  }

  convertSpeed(speed) {
    if(this.get('speedUnits') === 'mph') {
      return util.speedToMPH(speed);
    } else {
      return speed;
    }
  }

  convertPrecip(amt) {
    if(this.get('precipitationUnits') === 'in') {
      return util.lengthToInches(amt);
    } else {
      return amt;
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
    const pages = [{
      id: 'current',
      name: 'Now',
      view: () => new CurrentConditionsView({model: this})
    }];
    if(conditions.forecastHours != null)
      pages.push({
        id: 'hourly',
        name: 'Hourly',
        view: () => new HourlyForecastView({model: this})
      });
    if(conditions.forecastDays != null)
      pages.push({
        id: 'daily',
        name: 'Daily',
        view: () => new DailyForecastView({model: this})
      });
    _.findWhere(pages, {id: this.get('page')}).active = true;
    return pages;
  }

  rawCondition(cond) {
    return this.get('state').conditions[cond];
  }
  
  dailyForecast() {
    const days = this.get('state').conditions.forecastDays;
    if(days == null) return null;
    return days.map((day) => {
      const date = moment(day.time);
      return {
        conditionIcon:   util.weatherConditionToIcon(day.condition),
        conditionName:   util.weatherConditionToName(day.condition),
        highTemperature: this.formatTemp(day.highTemperature),
        lowTemperature:  this.formatTemp(day.lowTemperature),
        pop:             this.formatPop(day.pop),
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
        hour:              moment(hour.time).format('ha'),
        conditionIcon:     util.weatherConditionToIcon(hour.condition,
                                                       hour.dayNight),
        temperature:       this.convertTemp(hour.temperature),
        temperatureString: this.formatTemp(hour.temperature),
        nonzeroPop:        hour.pop > 0,
        pop:               this.formatPop(hour.pop),
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

  precipitation() {
    const conds = this.get('state').conditions;
    const precip = {};
    if(conds.precipitationRate != null && conds.precipitationRate > 0)
      precip.rate = this.formatPrecip(conds.precipitationRate) +
      ` ${this.get('precipitationUnits')}/hr`;
    if(conds.precipitationQuantity24Hour != null &&
      conds.precipitationQuantity24Hour > 0)
      precip.qty = this.formatPrecip(conds.precipitationQuantity24Hour) +
      ` ${this.get('precipitationUnits')}`;
    if(_.isEmpty(precip))
      return null; // No rain to speak of
    else
      return precip;
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
    if(conditions.imageResource != null) {
      return util.resourceURI(conditions.imagePath, conditions.imageResource);
    } else if(conditions.imageLocation != null) {
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

  showAlert(id) {
    const alert = _.findWhere(this.alerts(), {id: id});
    const view = new WeatherAlertView({model: alert});
    window.app.view.showModalView('Weather Alert', view);
  }
}
