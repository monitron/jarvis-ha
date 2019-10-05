const d3 = require('d3');
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

  formatStatus(status, isHome, distanceFromHome) {
    const text = [{
      disconnected: 'On battery',
      stopped:      'Charging stopped',
      charging:     'Charging',
      done:         'Done charging',
      off:          'Powered off',
      parked:       'In Park',
      driving:      'Driving',
      unknown:      'Unknown status'
    }[status]];
    if(isHome === true) {
      text.push('at home');
    } else if(distanceFromHome != null) {
      text.push(this.formatDistance(distanceFromHome), 'away');
    }
    return text.join(" ");
  }

  formatDistance(value) {
    if(value == null) return null;
    const units = this.get('distanceUnits');
    let dist = value;
    if(units === 'mi') dist = util.distanceToMiles(dist);
    return d3.format(`.${this.get('distancePrecision')}f`)(dist) +
      ' ' + units;
  }

  formatBatteryLevel(level) {
    if(level == null) return null;
    return `${Math.round(level * 100)}%`;
  }

  formatBatteryIcon(level) {
    if(level == null) return null;
    if(level <= 0.125) {
      return 'fa-battery-empty';
    } else if(level <= 0.375) {
      return 'fa-battery-quarter';
    } else if(level <= 0.625) {
      return 'fa-battery-half';
    } else if(level <= 0.875) {
      return 'fa-battery-three-quarters';
    } else {
      return 'fa-battery-full';
    }
  }

  formatAsOf(asOf) {
    if(asOf == null) return null;
    return moment(asOf).fromNow();
  }

  formatChargeDoneAt(asOf, timeRemaining) {
    if(asOf == null || timeRemaining == null) return null;
    return moment(asOf).add(timeRemaining, 'seconds').format('h:mma');
  }

  vehiclesForSummaryCard() {
    return _.map(this.get('state').vehicles, (vehicle, id) => {
      const sensors = vehicle.sensorValues || {};
      return {
        id,
        name: vehicle.name,
        batteryLevelText: this.formatBatteryLevel(sensors.batteryLevelSensor),
        batteryLevelIcon: this.formatBatteryIcon(sensors.batteryLevelSensor),
        status: this.formatStatus(vehicle.status, vehicle.isHome, vehicle.distanceFromHome),
        rangeText: this.formatDistance(sensors.vehicleRangeSensor),
        chargeDoneAt: this.formatChargeDoneAt(vehicle.asOf, sensors.chargingTimeRemainingSensor),
        asOf: this.formatAsOf(vehicle.asOf)
      }
    });
  }
}
