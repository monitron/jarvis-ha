
const _ = require('underscore');
const [Capability] = require('../../Capability.js');
const ComfortCapabilityView = require('./ComfortCapabilityView.js');

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
    return value;
  }

  sensorDisparities(aspect) {
    const state = this.get('state')[this.get('zone')];
    const thermValue = (state.thermostat || {})[aspect];
    const rooms = _.chain(state.sensors)
      .map((sensors, roomId) => {
        console.log(sensors, roomId);
        return {
          room:       roomId,
          roomName:   this.roomName(roomId),
          absolute:   sensors[aspect],
          difference: thermValue - sensors[aspect],
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
