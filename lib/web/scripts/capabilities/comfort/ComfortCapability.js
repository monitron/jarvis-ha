
const d3 = require('d3');
const _ = require('underscore');
const [Capability] = require('../../Capability.js');
const ComfortCapabilityView = require('./ComfortCapabilityView.js');
const util = require('../../util.coffee');

module.exports = class ComfortCapability extends Capability {
  name = 'Comfort';
  icon = 'thermometer-three-quarters';
  view = ComfortCapabilityView;

  initialize() {
    // Cheat for now; assume a single zone
    const zoneIds = _.keys(this.get('zones'));
    if(zoneIds.length > 0) this.set('zone', _.keys(this.get('zones'))[0]);
  }

  roomName(room) {
    const roomDetails = this.get('zones')[this.get('zone')].rooms[room];
    if(roomDetails.name) {
      return roomDetails.name;
    } else {
      return roomDetails.location.slice(-1)[0];
    }
  }

  formatSensorValue(aspect, value) {
    if(value == null) return undefined;
    switch(aspect) {
    case 'temperatureSensor':
      let temp = value;
      if(this.get('temperatureUnits') === 'f')
        temp = util.tempToFahrenheit(temp);
      return d3.format(`.${this.get('temperaturePrecision')}f`)(temp) + '&deg;';
      break;

    case 'humiditySensor':
      return d3.format(`.${this.get('humidityPrecision')}f`)(value) + '%';
      
    default:
      return value;
    }
  }

  currentZoneState() {
    const state = this.get('state')[this.get('zone')];
    return {
      temperatureFormatted: this.formatSensorValue('temperatureSensor',
        state.thermostat.temperatureSensor),
      humidityFormatted: this.formatSensorValue('humiditySensor',
        state.thermostat.humiditySensor)
    };
  }

  sensorDisparities(aspect) {
    const state = this.get('state')[this.get('zone')];
    const thermValue = (state.thermostat || {})[aspect];
    const rooms = _.chain(state.sensors)
      .map((sensors, roomId) => {
        return {
          room:       roomId,
          roomName:   this.roomName(roomId),
          absolute:   sensors[aspect],
          difference: sensors[aspect] - thermValue,
          formatted:  this.formatSensorValue(aspect, sensors[aspect])
        };
      }).filter((room) => room.absolute != null)
      .sortBy('difference')
      .value();
    return {
      rooms: rooms,
      thermostat: thermValue
    };
  }
}
