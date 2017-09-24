
const Marionette = require('backbone.marionette');
const EventsView = require('./EventsView.js');

module.exports = class EventBrowserView extends Marionette.View {
  template = Templates['events/event-browser'];

  regions() {
    return {
      events: '.events-container'
    };
  }

  className() {
    return "event-browser";
  }

  ui() {
    return {
      refreshButton: '.refresh',
      querySpinner:  '.refresh i',
      pageSelect:    '.select li'
    };
  }

  events() {
    return {
      'click @ui.refreshButton': 'onClickRefresh',
      'click @ui.pageSelect':    'onClickPageSelect'
    };
  }

  modelEvents() {
    return {
      change: 'render',
      'query:loading': 'indicateLoading',
      'query:done': 'indicateNotLoading'
    };
  }

  serializeData() {
    return {
      page:  this.model.get('page'),
      pages: this.model.pages()
    };
  }

  onRender() {
    const view = new EventsView({
      collection: this.model.eventCollection(),
      historical: this.model.get('page') == 'history'
    });
    this.showChildView('events', view);
  }
  
  onClickPageSelect(ev) {
    const id = $(ev.target).data('id');
    this.model.set('page', id);
  }

  onClickRefresh(ev) {
    ev.preventDefault();
    this.model.query();
  }

  indicateLoading() {
    this.ui.querySpinner.addClass('fa-spin');
  }

  indicateNotLoading() {
    this.ui.querySpinner.removeClass('fa-spin');
  }
}
