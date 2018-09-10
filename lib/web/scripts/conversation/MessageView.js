
const Marionette = require('backbone.marionette');

module.exports = class MessageView extends Marionette.View {
  template = Templates['conversation/message'];

  className() {
    return 'message-container';
  }
  
  modelEvents() {
    return {
      change: 'render'
    };
  }
}
