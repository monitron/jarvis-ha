
const Marionette = require('backbone.marionette');

module.exports = class EventView extends Marionette.View {
  template = Templates['event'];

  className() {
    return `event ${this.model.get('importance')}-importance`;
  }

  serializeData() {
    const data = {title: this.model.get('title')};
    switch(this.model.get('sourceType')) {
    case 'capability':
      const cap = window.app.capabilities.get(this.model.get('sourceId'));
      data.sourceIcon = cap.icon;
      data.sourceName = cap.name;
      break;
      
    case 'control':
      const ctrl = window.app.controls.get(this.model.get('sourceId'));
      data.sourceIcon = 'toggle-on';
      data.sourceName = ctrl.get('name');
      break;

    default:
      data.sourceIcon = 'cogs';
      data.sourceName = 'System';
    }

    return data;
  }
}
