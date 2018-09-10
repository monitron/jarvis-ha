
const _ = require('underscore');
const Marionette = require('backbone.marionette');
const MessagesView = require('./MessagesView.js');

module.exports = class ConversationView extends Marionette.View {
  template = Templates['conversation/conversation'];
  
  className() {
    return 'conversation';
  }

  regions() {
    return {
      messages: '.messages'
    };
  }

  ui() {
    return {
      messages:  '.messages',
      micButton: '.microphone-button',
      textInput: '.text-input'
    };
  }

  events() {
    return {
      'click @ui.micButton': 'onClickMicButton',
      'keypress @ui.textInput': 'onTextInputKeypress'
    };
  }

  modelEvents() {
    return {
      'change:listening': 'updateListening'
    };
  }

  initialize() {
    this.listenTo(this.model.messages, 'add', () => { _.defer(() => {
      this.ui.messages.scrollTop(this.ui.messages[0].scrollHeight);
    })});
    if(window.hasOwnProperty('SpeechRecognition')) {
      this.speech = new window.SpeechRecognition();
    } else if(window.hasOwnProperty('webkitSpeechRecognition')) {
      this.speech = new window.webkitSpeechRecognition();
    }
    if(this.speech != null) {
      this.speech.onresult     = (event) => this.onSpeechResult(event);
      this.speech.onaudiostart = (event) => this.onSpeechStart(event);
      this.speech.onaudioend   = (event) => this.onSpeechEnd(event);
    }
  }

  onRender() {
    const messagesView = new MessagesView({collection: this.model.messages});
    this.showChildView('messages', messagesView);
    this.updateListening();
    _.defer(() => { if(this.hasTextInput()) this.ui.textInput.focus() });
  }

  hasTextInput() {
    return window.app.displayType() != 'touchscreen';
  }

  serializeData() {
    return {
      hasVoiceInput: this.speech != null,
      hasTextInput: this.hasTextInput()
    };
  }

  onClickMicButton() {
    if(this.model.get('listening')) {
      this.speech.abort();
    } else {
      this.speech.start();
    }
  }

  onTextInputKeypress(ev) {
    if(ev.which == 13) {
      ev.preventDefault();
      this.model.sendUserMessage(this.ui.textInput.val());
      this.ui.textInput.val('').focus();
    }
  }

  onSpeechResult(event) {
    const spoken = _.last(event.results)[0].transcript;
    this.model.sendUserMessage(spoken).then((response) => {
      const ut = new SpeechSynthesisUtterance(response);
      window.speechSynthesis.speak(ut);
    });
  }

  onSpeechStart() {
    this.model.set('listening', true);
  }
  
  onSpeechEnd() {
    this.model.set('listening', false);
  }

  onBeforeDestroy() {
    if(this.speech != null) this.speech.abort();
  }

  updateListening() {
    this.ui.micButton.toggleClass('listening', this.model.get('listening'));
  }
}
