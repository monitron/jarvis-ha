
const _ = require("underscore");
const Backbone = require("backbone");
const moment = require("moment");
const [Event, Events] = require("../Event.js");
const EventQueryView = require("./EventQueryView.js");
const EventQuery = require("./EventQuery.js");
const EventsView = require('./EventsView.js');

module.exports = class EventBrowser extends Backbone.Model {
  defaults() {
    return {
      'page': 'ongoing'
    };
  }

  initialize() {
    // Automatically query when changing to history page
    this.historyQuery = new EventQuery({lastHours: 6});
    this.listenTo(this, 'change:page',
                  (m, value) => {if(value == 'history') this.historyQuery.run()});
  }
  
  pages() {
    const pages = [
      {
        id: 'ongoing',
        name: 'Current',
        view: () => new EventsView({collection: window.app.events})
      },
      {
        id: 'history',
        name: 'History',
        view: () => new EventQueryView({model: this.historyQuery})
      }
    ];
    _.findWhere(pages, {id: this.get('page')}).active = true;
    return pages;
  }
}
