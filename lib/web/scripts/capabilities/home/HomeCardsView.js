const Marionette = require('backbone.marionette');
const HomeCardView = require('./HomeCardView.js');

module.exports = class HomeCardsView extends Marionette.CollectionView {
  childView = HomeCardView;

  className() { return 'home-cards'; }

  viewComparator(child) { return child.numericPriority(); }
}
