
const _ = require('underscore');
const Marionette = require('backbone.marionette');

module.exports = class EventView extends Marionette.View {
  template = Templates['events/event'];
  timeFormat = 'h:mma';

  className() {
    const classes = ['event'];
    classes.push(`${this.model.get('importance')}-importance`);
    if(this.options.historical) classes.push('historical');
    return classes.join(' ');
  }

  serializeData() {
    const startTime = this.model.getStartTime();
    var endTime = this.model.getEndTime();
    if(startTime.isSame(endTime)) {
      endTime = null;
    } else if(_.isUndefined(endTime)) {
      endTime = 'Now';
    } else {
      endTime = endTime.format(this.timeFormat);
    }
    
    const data = {
      title: this.model.get('title'),
      historical: this.options.historical,
      start: startTime.format(this.timeFormat),
      end: endTime
    };
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
