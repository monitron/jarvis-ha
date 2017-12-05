const Marionette = require('backbone.marionette');
const HomeCardsView = require('./HomeCardsView.js');

module.exports = class HomeCapabilityView extends Marionette.View {
  template = Templates['capabilities/home/home'];

  className() {
    return 'home-capability';
  }

  regions() {
    return {cards: '.cards-container'};
  }

  serializeData() {
    const hour = (new Date()).getHours();
    // XXX Force this to update occasionally
    return {
      greeting: (hour < 4 || hour >= 7) ? 'Good evening.' :
        ((hour < 12) ? 'Good morning.' : 'Good afternoon.')
    };
  }

  onRender() {
    this.showChildView('cards',
                       new HomeCardsView({collection: window.app.cards}));
  }
}
