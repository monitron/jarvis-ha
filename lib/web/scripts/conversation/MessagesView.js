
const Marionette = require('backbone.marionette');
const MessageView = require('./MessageView.js');

module.exports = class MessagesView extends Marionette.CollectionView {
  childView = MessageView;
}
