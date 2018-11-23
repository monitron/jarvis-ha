const _ = require('underscore');
const moment = require('moment');
const [Capability] = require('../../Capability.js');
const VehicleSummaryCardView = require('./VehicleSummaryCardView.js');
const util = require('../../util.coffee');

module.exports = class PeopleCapability extends Capability {
  name = 'Vehicles';
  icon = 'car';
  cardViews = {
    summary: VehicleSummaryCardView
  }

  initialize(attrs, options) {
    super.initialize(attrs, options);
    this.addCard({
      type: 'summary',
      priority: 'low'
    });
  }

  titleForSummaryCard() {
    const summarize = (vehs, singular, plural) => {
      if(vehs.length === 1) {
        return `${vehs[0].name} ${singular}`;
      } else {
        return `${vehs.length} vehicles ${plural}`;
      }
    }
    const vehicles = _.map(this.get('state').vehicles, (vehicle, id) => {
      return {
        name: vehicle.name,
        status: vehicle.sensorValues &&
          vehicle.sensorValues.chargingStatusSensor
      }
    });
    const statuses = _.groupBy(vehicles, (v) => v.status);
    if(statuses.stopped != null) {
      return summarize(statuses.stopped,
                       'has stopped charging', 'have stopped charging');
    } else if(statuses.done != null) {
      return summarize(statuses.done,
                       'is done charging', 'are done charging');
    } else if(statuses.charging != null) {
      return summarize(statuses.charging, 'is charging', 'are charging');
    } else if(statuses.disconnected != null) {
      return summarize(statuses.disconnected,
                       'is on battery', 'are on battery');
    } else {
      return summarize(vehicles,
                       'status unknown', 'with unknown status');
    }
  }

  formatChargingStatus(status) {
    return {
      disconnected: 'On battery',
      stopped:      'Charging stopped',
      charging:     'Charging',
      done:         'Done charging'
    }[status] || 'Unknown status';
  }

  formatBatteryLevel(level) {
    if(level == null) return null;
    return `${Math.round(level * 100)}%`;
  }

  formatRange(range) {
    if(range == null) return null;
    const rangeMi = Math.round(util.distanceToMiles(range));
    return `${rangeMi} mi`;
  }

  formatAsOf(asOf) {
    if(asOf == null) return null;
    return moment(asOf).fromNow();
  }

  vehiclesForSummaryCard() {
    return _.map(this.get('state').vehicles, (vehicle, id) => {
      const sensors = vehicle.sensorValues || {};
      return {
        id,
        name: vehicle.name,
        batteryLevelText: this.formatBatteryLevel(sensors.batteryLevelSensor),
        chargingStatus: this.formatChargingStatus(sensors.chargingStatusSensor),
        rangeText: this.formatRange(sensors.vehicleRangeSensor),
        asOf: this.formatAsOf(vehicle.asOf)
      }
    });
  }
}
