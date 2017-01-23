
const Marionette = require('backbone.marionette');
const CapabilityIconsView = require('./CapabilityIconsView.js');
const NotificationBadgeView = require('./NotificationBadgeView.js');

module.exports = class PhoneNavView extends Marionette.View {
  template = Templates['nav/phone'];

  modelEvents() {
    return {
      'change:capability': 'updateCurrentCapability'
    };
  }

  ui() {
    return {
      currentCapability: '.current-capability',
      togglers: '.hamburger, .header, .selected, .shade',
      drawer: '.drawer'
    };
  }

  events() {
    return {
      'click @ui.togglers': 'toggleDrawer',
      'click .debug-icon': 'showDebug'
    };
  }

  regions() {
    return {
      capabilities: '.capabilities',
      notifications: '.notifications'
    };
  }

  onRender() {
    this.updateCurrentCapability();
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

  updateCurrentCapability() {
    const capability = this.model.currentCapability();
    this.ui.currentCapability.text(capability != null ? capability.name : '');
    this.ui.drawer.removeClass('visible');
  }

  toggleDrawer() {
    this.ui.drawer.toggleClass('visible');
  }
}
