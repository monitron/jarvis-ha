
const _ = require("underscore");
const moment = require("moment");
const Backbone = require("backbone");
const [Event, Events] = require("../../../Event.js");
const EventQuery = require("../../../events/EventQuery.js");
const EventQueryView = require("../../../events/EventQueryView.js");

module.exports = class ControlDetails extends Backbone.Model {
  defaults() {
    return {
      'page': 'history'
    };
  }

  initialize() {
    this.historyQuery = new EventQuery({
      lastHours:  24,
      sourceType: 'control',
      sourceId:   this.get('control').id
    });
    this.historyQuery.run(); // Later perhaps only when changing page
  }
  
  pages() {
    const pages = [
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
