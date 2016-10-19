
const Marionette = require('backbone.marionette');
const ControlContainerView = require('./ControlContainerView.js');

module.exports = class ControlContainersView extends Marionette.CollectionView {
  childView = ControlContainerView;

  className() { return 'controls-list'; }

  filter(child, index, collection) {
    const membership = child.getMembership(this.getOption('path'));
    return membership != null && child.get('context') === 'main' &&
      child.get('valid');
  }

  viewComparator(child) {
    const membership = child.getMembership(this.getOption('path'));
    if(membership != null) {
      return membership.priority || 0;
    } else {
      return 0;
    }
  }
}
