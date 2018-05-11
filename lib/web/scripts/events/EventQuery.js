
const _ = require("underscore");
const Backbone = require("backbone");
const moment = require("moment");
const [Event, Events] = require("../Event.js");

module.exports = class EventQuery extends Backbone.Model {
  defaults() {
    return {
      lastHours: 6
    };
  }
  
  initialize() {
    this.results = new Events();
  }
  
  run() {
    const predicates = {};
    if(this.has('lastHours')) {
      predicates.timesStart =
        moment().subtract(this.get('lastHours'), 'hour').unix();
      predicates.timesEnd = moment().unix();
    }
    _.extend(predicates, _.omit(this.toJSON(), 'lastHours'));
    const promise = Events.search(predicates);
    this.results.reset();
    this.trigger('loading');
    promise.done((results) => {
      this.results.reset(results.toJSON());
      this.trigger('done');
    });
  }
}
