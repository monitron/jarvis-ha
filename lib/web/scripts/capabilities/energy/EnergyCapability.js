
const Backbone = require("backbone");
const _ = require('underscore');
const d3 = require('d3');
const [Capability] = require('../../Capability.js');
const EnergyCapabilityView = require('./EnergyCapabilityView.js');
const EnergyCapabilityIdleView = require('./EnergyCapabilityIdleView.js');

module.exports = class EnergyCapability extends Capability {
  name = 'Energy';
  icon = 'bolt';
  view = EnergyCapabilityView;
  idleView = EnergyCapabilityIdleView;

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
}
