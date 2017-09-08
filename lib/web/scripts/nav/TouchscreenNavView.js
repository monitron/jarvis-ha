
const Marionette = require('backbone.marionette');
const moment = require('moment');
const CapabilityIconsView = require('./CapabilityIconsView.js');
const NotificationBadgeView = require('./NotificationBadgeView.js');

module.exports = class TouchscreenNavView extends Marionette.View {
  template = Templates['nav/touchscreen'];

  events() {
    return {
      'click .debug-icon': 'showDebug'
    };
  }

  regions() {
    return {
      capabilities: '.capabilities',
      notifications: '.notifications'
    };
  }

  initialize() {
    this.clockRefreshInterval = setInterval(this.render.bind(this), 10000);
  }

  serializeData() {
    const now = moment();
    return {
      time: now.format('h:mm a'),
      day:  now.format('ddd M/D')
    };
  }
  
  onRender() {
    const capsView = new CapabilityIconsView({
      collection: this.model.capabilities,
      model: this.model
    });
    this.showChildView('capabilities', capsView);
    const notifsView = new NotificationBadgeView({
      model: this.model.events
    });
    this.showChildView('notifications', notifsView);
  }

  showDebug() {
    this.model.showDebug();
  }

  onDestroy() {
    clearInterval(this.clockRefreshInterval);
  }
}
