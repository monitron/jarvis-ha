
const Backbone = require('backbone');

class Card extends Backbone.Model {
  numericPriority() {
    return ['high', 'medium', 'low'].indexOf(this.get('priority'));
  }

  capability() {
    return window.app.capabilities.get(this.get('capability'));
  }

  bodyView() {
    const viewClass = this.capability().cardViews[this.get('type')];
    return new viewClass({model: this});
  }
}

class Cards extends Backbone.Collection {
}

module.exports = [Card, Cards];
