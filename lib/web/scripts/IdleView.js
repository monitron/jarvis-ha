
const Marionette = require('backbone.marionette');
const moment = require('moment');

module.exports = class IdleView extends Marionette.View {
  template = Templates['idle'];

  className() { return 'idle-content'; }

  events() {
    return {'click': 'hide'};
  }

  onRender() {
    this.timeRefresh = setInterval(this.render.bind(this), 10000);
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

  hide() {
    this.trigger('hide');
  }

  onDestroy() {
    clearInterval(this.timeRefresh);
  }
}
