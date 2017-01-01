const _ = require('underscore');
const [baseEvent, baseEvents] = require('../../Event.coffee');

class Event extends baseEvent {
}

class Events extends baseEvents {
  url = 'api/events';
  model = Event;
}

module.exports = [Event, Events];
