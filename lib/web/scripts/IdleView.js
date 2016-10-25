
const Marionette = require('backbone.marionette');
const moment = require('moment');

module.exports = class IdleView extends Marionette.View {
  template = Templates['idle'];

  className() { return 'idle-content'; }

  regions() {
    return {capability: '.capability'};
  }

  events() {
    return {'click': 'hide'};
  }

  initialize() {
    this.capabilities = this.model.capabilitiesWithIdleViews();
    this.capabilityIndex = -1;
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
    if(this.capabilities.length > 0) {
      this.capabilityIndex += 1;
      if(this.capabilityIndex >= this.capabilities.length)
        this.capabilityIndex = 0;
      const cap = this.capabilities[this.capabilityIndex];
      this.showChildView('capability', new cap.idleView({model: cap}));
    }
  }

  hide() {
    this.trigger('hide');
  }

  onDestroy() {
    clearInterval(this.refreshInterval);
  }
}
