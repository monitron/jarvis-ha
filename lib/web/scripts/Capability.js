const _ = require('underscore');
const [baseCapability, baseCapabilities] = require('../../Capability.coffee');
const [Card, Cards] = require('./Card.js');

class Capability extends baseCapability {
  initialize(attrs, options) {
    super.initialize(attrs, options);
    this._valid = this.get('valid');
    this._tasks = [];
  }

  addTask(promise) {
    this._tasks.push(promise);
    this.trigger('task:started');
    if(this._tasks.length == 1) this.trigger('task:some');
    promise.done(() => this.trigger('task:done', promise));
    promise.fail(() => this.trigger('task:fail', promise));
    promise.always(() => {
      this._tasks = _.without(this._tasks, promise);
      if(_.isEmpty(this._tasks)) this.trigger('task:none');
    });
  }

  sendCommand(commandId, params = {}) {
    const promise = $.ajax({
      url: `api/capabilities/${this.id}/commands/${commandId}`,
      type: 'POST',
      data: params
    });
    this.addTask(promise);
    return promise;
  }

  addCard(attributes) {
    attributes = _.defaults(attributes, {capability: this.id});
    const card = new Card(attributes);
    window.app.cards.add(card);
    return card;
  }

  cardsWhere(attributes) {
    return window.app.cards.where(
      _.defaults(attributes, {capability: this.id}));
  }

  cardWhere(attributes) {
    return window.app.cards.findWhere(
      _.defaults(attributes, {capability: this.id}));
  }

  removeCardsWhere(attributes) {
    window.app.cards.remove(this.cardsWhere(attributes));
  }

  visit() {
    window.app.visitCapability(this.id);
  }

  // Override to return available home screen shortcuts
  shortcuts() {
    return [];
  }
}
  
class Capabilities extends baseCapabilities {
  url = 'api/capabilities';

  model(attrs, options) {
    const klass = require('./capabilities/index.js')[attrs.id];
    return new klass(attrs, options);
  }
}

module.exports = [Capability, Capabilities];
