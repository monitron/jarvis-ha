
const Backbone = require("backbone");
const _ = require('underscore');
const d3 = require('d3');
const [Capability] = require('../../Capability.js');
const EnergyCapabilityView = require('./EnergyCapabilityView.js');
const EnergyCapabilityIdleView = require('./EnergyCapabilityIdleView.js');
const EnergyMetersView = require('./EnergyMetersView.js');
const EnergyConsumersView = require('./EnergyConsumersView.js');

module.exports = class EnergyCapability extends Capability {
  name = 'Energy';
  icon = 'bolt';
  view = EnergyCapabilityView;
  idleViews = [EnergyCapabilityIdleView];

  defaults() {
    return {
      'page': 'meters'
    };
  }

  currentPeriodNames = {
    'day':   'Today',
    'month': 'This Month',
    'year':  'This Year'
  };

  formatEnergy(value, precision) {
    return d3.format(`.${precision}f`)(value);
  }

  formatOffset(ratio) {
    return d3.format('.0%')(ratio);
  }

  metersByPeriod() {
    return new Backbone.Collection(
      _.map(this.get('state').meters, (periodData, period) => {
        const max = d3.max(_.values(periodData.meters));
        const precision = max >= 1000 ? 0 : 1;
        return {
          id: period,
          name: this.currentPeriodNames[period],
          meters: _.map(periodData.meters, (meterValue, meter) => {
            const meterDetails = this.get('meters')[meter] || {};
            return {
              meter: meter,
              meterName: meterDetails.name,
              meterIcon: meterDetails.icon || 'tachometer',
              formattedValue: this.formatEnergy(meterValue, precision),
              proportionalValue: Math.round((meterValue / max) * 100)
            };
          }),
          offsets: _.map(periodData.offsets, (offsetValue, offset) => {
            const offsetDetails = this.get('offsets')[offset] || {};
            return {
              offset: offset,
              offsetName: offsetDetails.name,
              formattedValue: this.formatOffset(offsetValue)
            };
          })
        };
      })
    );
  }

  consumers() {
    const consumers = this.get('state').currentConsumption;
    const maxRate = d3.max(consumers.map((cons) => cons.rate));
    return _.sortBy(consumers, (cons) => -cons.rate).map((cons) => {
      return {
        name: cons.name,
        proportionalValue: Math.round((cons.rate / maxRate) * 100),
        formattedValue: this.formatEnergy(cons.rate, 0)
      }
    });
  }

  pages() {
    const pages = [
      {
        id: 'meters',
        name: 'Meters',
        view: () => new EnergyMetersView({model: this})
      },
      {
        id: 'consumers',
        name: 'Consumers',
        view: () => new EnergyConsumersView({model: this})
      }
    ];
    _.findWhere(pages, {id: this.get('page')}).active = true;
    return pages;
  }
}
