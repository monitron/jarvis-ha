const Marionette = require('backbone.marionette');
const HomeCardView = require('./HomeCardView.js');

module.exports = class HomeCardsView extends Marionette.CollectionView {
  childView = HomeCardView;

  emptyView = Marionette.View.extend({
    template: () => '<div class="empty">No news is good news.</div>'
  });

  className() { return 'home-cards'; }

  viewComparator(child) { return child.numericPriority(); }
}
