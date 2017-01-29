
const Marionette = require('backbone.marionette');
const moment = require('moment');
const EventsView = require('./events/EventsView.js');

module.exports = class IdleView extends Marionette.View {
  template = Templates['idle'];

  className() { return 'idle-content'; }

  regions() {
    return {
      capability: '.capability',
      notifications: '.notifications'
    };
  }

  events() {
    return {'click': 'hide'};
  }

  initialize() {
    this.views = this.model.idleViews();
    this.viewIndex = -1;
    // The refresh interval both updates the time display and displays
    // the next capability idle view.
    this.refreshInterval = setInterval(this.render.bind(this), 10000);
  }

  serializeData() {
    const now = moment();
    return {
      time: now.format('h:mm'),
      ampm: now.format('a'),
      day:  now.format('dddd'),
      date: now.format('MMM Do, Y')
    };
  }

  onRender() {
    if(this.views.length > 0) {
      this.viewIndex += 1;
      if(this.viewIndex >= this.views.length) this.viewIndex = 0;
      const [cap, view] = this.views[this.viewIndex];
      this.showChildView('capability', new view({model: cap}));
    }
    this.showChildView('notifications', new EventsView({
      collection: this.model.events
    }));
  }

  hide() {
    this.trigger('hide');
  }

  onDestroy() {
    clearInterval(this.refreshInterval);
  }
}
