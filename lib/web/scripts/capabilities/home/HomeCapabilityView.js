const Marionette = require('backbone.marionette');

module.exports = class HomeCapabilityView extends Marionette.View {
  template() {
    return '<div class="cards-container"></div>';
  }

  classNme() {
    return 'home-capability';
  }

  regions() {
    return {cards: '.cards'};
  }

  onRender() {
    
  }
}
