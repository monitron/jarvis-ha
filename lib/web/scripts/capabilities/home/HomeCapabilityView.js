const Marionette = require('backbone.marionette');
const HomeCardsView = require('./HomeCardsView.js');

module.exports = class HomeCapabilityView extends Marionette.View {
  template() {
    return '<div class="cards-container"></div>';
  }

  className() {
    return 'home-capability';
  }

  regions() {
    return {cards: '.cards-container'};
  }

  onRender() {
    this.showChildView('cards',
                       new HomeCardsView({collection: window.app.cards}));
  }
}
