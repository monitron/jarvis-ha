const Backbone = require('backbone');
const Q = require('q');
const [Message, Messages] = require('./Message.js');

module.exports = class Conversation extends Backbone.Model {
  defaults() {
    return {
      listening: false
    };
  }
  
  initialize() {
    this.messages = new Messages([
      {from: 'system', text: 'How may I help you?'}
    ]);
  }

  sendUserMessage(text) {
    const d = Q.defer()
    this.messages.add({from: 'user', text: text});
    const responseMsg = this.messages.add({from: 'system', incomplete: true});
    const request = $.ajax({
      url: `api/natural/${encodeURIComponent(text)}`,
      type: 'POST'
    });
    request.done((data) => {
      responseMsg.set({
        style: data.success ? 'normal' : 'error',
        text: data.response,
        incomplete: false
      });
      d.resolve(data.response);
    });
    request.fail(() => {
      const err = 'Sorry, an unexpected error occurred. Please try again.';
      responseMsg.set({
        style: 'error',
        text: err,
        incomplete: false
      });
      d.resolve(err);
    });
    return d.promise;
  }
}
