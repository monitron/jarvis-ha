const Backbone = require('backbone');

class Message extends Backbone.Model {
  defaults() {
    return {
      style: 'normal',  // or 'error'
      incomplete: false // shows typing indicator
    };
  }
}

class Messages extends Backbone.Collection {
  model = Message
}

module.exports = [Message, Messages];
