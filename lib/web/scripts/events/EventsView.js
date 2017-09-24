
const Marionette = require('backbone.marionette');
const EventView = require('./EventView.js');

module.exports = class EventsView extends Marionette.CollectionView {
  childView = EventView;

  className() {
    return 'events';
  }

  childViewOptions(model, index) {
    return {
      historical: this.options.historical
    };
  }
}
