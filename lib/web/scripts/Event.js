const _ = require('underscore');
const moment = require('moment');
const [baseEvent, baseEvents] = require('../../Event.coffee');

class Event extends baseEvent {
  getStartTime() {
    if(_.isString(this.get('start'))) return moment(this.get('start'));
  }
  
  getEndTime() {
    if(_.isString(this.get('end'))) return moment(this.get('end'));
  }
}

class Events extends baseEvents {
  url = 'api/events';
  model = Event;

  static search(query) {
    const promise = $.ajax({
      url: "api/events/search",
      dataType: 'json',
      data: query
    });
    return promise.then((data) => new Events(data));
  }
}

module.exports = [Event, Events];
