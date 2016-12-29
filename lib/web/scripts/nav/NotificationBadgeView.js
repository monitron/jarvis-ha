
const Marionette = require('backbone.marionette');

module.exports = class NotificationBadgeView extends Marionette.View {
  template = Templates['nav/notification-badge'];

  modelEvents() {
    return {
      'reset add remove': 'render'
    };
  }

  events() {
    return {
      'click': 'onClick'
    };
  }

  className() {
    const classes = ['badge'];
    const importance = this.model.greatestImportance();
    if(importance != null) classes.push(`${importance}-importance`);
    return classes.join(' ');
  }

  onRender() {
    this.$el.attr('class', this.className());
  }

  onClick() {
    window.app.displayEvents();
  }

  serializeData() {
    return {
      number: this.model.length,
      any: this.model.length > 0
    };
  }
}
