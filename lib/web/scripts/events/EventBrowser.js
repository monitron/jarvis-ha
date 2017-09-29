
const _ = require("underscore");
const Backbone = require("backbone");
const moment = require("moment");
const [Event, Events] = require("../Event.js");

module.exports = class EventBrowser extends Backbone.Model {
  defaults() {
    return {
      'page': 'ongoing'
    };
  }

  initialize() {
    this.results = new Events();
    // Automatically query when changing to history page
    this.listenTo(this, 'change:page',
                  (m, value) => {if(value == 'history') this.query()});
  }
  
  pages() {
    const pages = [
      {id: 'ongoing', name: 'Current'},
      {id: 'history', name: 'History'}
    ];
    _.findWhere(pages, {id: this.get('page')}).active = true;
    return pages;
  }

  eventCollection() {
    if(this.get('page') == 'ongoing') {
      return window.app.events;
    } else {
      return this.results;
    }
  }

  query() {
    const predicates = {
      timesStart: moment().subtract(6, 'hour').unix(),
      timesEnd:   moment().unix()
    };
    const promise = Events.search(predicates);
    this.results.reset();
    this.trigger('query:loading');
    promise.done((results) => {
      this.results.reset(results.toJSON());
      this.trigger('query:done');
    });
  }
}
