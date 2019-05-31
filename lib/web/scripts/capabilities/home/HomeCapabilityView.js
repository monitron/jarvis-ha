const Marionette = require('backbone.marionette');
const HomeCardsView = require('./HomeCardsView.js');
const ShortcutsView = require('./ShortcutsView.js');

module.exports = class HomeCapabilityView extends Marionette.View {
  template = Templates['capabilities/home/home'];

  className() {
    return 'home-capability';
  }

  ui() {
    return {
      greeting: '.greeting'
    };
  }
  
  regions() {
    return {
      cards: '.cards-container',
      shortcuts: '.shortcuts-container'
    };
  }

  initialize() {
    this.refreshInterval = setInterval(this.updateGreeting.bind(this),
                                       1000 * 60 * 5);
  }

  serializeData() {
    return {
      isPhone: window.app.get('display') === 'phone'
    };
  }

  updateGreeting() {
    const hour = (new Date()).getHours();
    const greeting = (hour < 4 || hour >= 19) ? 'Good evening' :
          ((hour < 12) ? 'Good morning' : 'Good afternoon');
    this.ui.greeting.text(greeting);
  }

  onRender() {
    this.updateGreeting();
    this.showChildView('cards',
                       new HomeCardsView({collection: window.app.cards}));
    this.showChildView('shortcuts',
                       new ShortcutsView({model: this.model}));
  }

  onDestroy() {
    clearInterval(this.refreshInterval);
  }
}
