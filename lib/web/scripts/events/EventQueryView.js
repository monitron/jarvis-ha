const Marionette = require('backbone.marionette');
const EventsView = require('./EventsView.js');

module.exports = class EventQueryView extends Marionette.View {
  template = Templates['events/query'];

  regions() {
    return {
      events: '.events-container'
    };
  }

  className() {
    return "event-query";
  }
  
  ui() {
    return {
      refreshButton: '.refresh',
      spinner:       '.refresh i'
    };
  }

  events() {
    return {
      'click @ui.refreshButton': 'onClickRefresh'
    };
  }

  modelEvents() {
    return {
      'loading': 'onQueryLoading',
      'done':    'onQueryDone',
    };
  }

  onRender() {
    const view = new EventsView({
      collection: this.model.results,
      historical: true,
      lastHours:  this.model.get('lastHours') // Kind of a big assumption
    });
    this.showChildView('events', view);
  }
  
  onClickRefresh(ev) {
    ev.preventDefault();
    this.model.run();
  }

  onQueryLoading() {
    this.ui.spinner.addClass('fa-spin');
  }

  onQueryDone() {
    this.ui.spinner.removeClass('fa-spin');
  }
}
