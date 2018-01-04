const Marionette = require('backbone.marionette');
const HomeCardsView = require('./HomeCardsView.js');
const ShortcutsView = require('./ShortcutsView.js');

module.exports = class HomeCapabilityView extends Marionette.View {
  template = Templates['capabilities/home/home'];

  className() {
    return 'home-capability';
  }

  regions() {
    return {
      cards: '.cards-container',
      shortcuts: '.shortcuts-container'
    };
  }

  initialize() {
    // Update the greeting...
    this.refreshInterval = setInterval(this.render.bind(this), 1000 * 60 * 5);
  }

  serializeData() {
    const hour = (new Date()).getHours();
    return {
      greeting: (hour < 4 || hour >= 19) ? 'Good evening' :
        ((hour < 12) ? 'Good morning' : 'Good afternoon')
    };
  }

  onRender() {
    this.showChildView('cards',
                       new HomeCardsView({collection: window.app.cards}));
    this.showChildView('shortcuts',
                       new ShortcutsView({model: this.model}));
  }

  onDestroy() {
    clearInterval(this.refreshInterval);
  }
}
