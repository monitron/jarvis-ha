
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

  formatEnergy(value) {
    return d3.format(`.${this.get('energyPrecision')}f`)(value);
  }

  metersByPeriod() {
    return new Backbone.Collection(
      _.map(this.get('meterSummary'), (meters, period) => {
        const max = d3.max(_.values(meters));
        return {
          id: period,
          name: this.currentPeriodNames[period],
          meters: _.map(meters, (meterValue, meter) => {
            const meterDetails = this.get('meters')[meter] || {};
            return {
              meter: meter,
              meterName: meterDetails.name,
              meterIcon: meterDetails.icon || 'tachometer',
              formattedValue: this.formatEnergy(meterValue),
              proportionalValue: Math.round((meterValue / max) * 100)
            }
          })
        };
      })
    );
  }
}
