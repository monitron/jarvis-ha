
const Marionette = require('backbone.marionette');
const CapabilityIconsView = require('./CapabilityIconsView.js');
const NotificationBadgeView = require('./NotificationBadgeView.js');

module.exports = class DesktopNavView extends Marionette.View {
  template = Templates['nav/desktop'];

  ui() {
    return {
      conversation: '.conversation-button'
    };
  }

  events() {
    return {
      'click @ui.conversation': 'showConversation'
    };
  }

  regions() {
    return {
      capabilities: '.capabilities',
      notifications: '.notifications'
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

  showConversation() {
    this.model.showConversation();
  }
}
