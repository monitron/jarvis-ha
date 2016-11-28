
const Marionette = require('backbone.marionette');

module.exports = class LocationPickerListView extends Marionette.View {
  template = Templates['location-picker/location-picker-list'];

  ui() {
    return {room: '.room'};
  }

  events() {
    return {'click @ui.room': 'onRoomClick'};
  }

  serializeData() {
    const currentRoom = this.getOption('current');
    return {
      rooms: this.getOption('rooms').map(function(room) {
        return {
          name: room.name,
          active: room.active,
          selected: room.name === currentRoom
        };
      })
    };
  }

  onRoomClick(event) {
    const room = $(event.target).closest('.room').data('room');
    this.trigger('select', room);
  }
}
