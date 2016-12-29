
const Marionette = require('backbone.marionette');
const EventView = require('./EventView.js');

module.exports = class EventsView extends Marionette.CollectionView {
  childView = EventView;

  className() {
    return 'events';
  }
}
