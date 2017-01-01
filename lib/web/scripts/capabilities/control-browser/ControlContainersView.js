
const Marionette = require('backbone.marionette');
const ControlContainerView = require('./ControlContainerView.js');

module.exports = class ControlContainersView extends Marionette.CollectionView {
  childView = ControlContainerView;

  className() { return 'controls-list'; }

  filter(child, index, collection) {
    const membership = this.membership(child);
    return membership != null && child.get('context') === 'main' &&
      child.get('valid');
  }

  viewComparator(child) {
    const membership = this.membership(child);
    if(membership != null) {
      return membership.priority || 0;
    } else {
      return 0;
    }
  }

  childViewOptions(child) {
    return {membership: this.membership(child)};
  }

  membership(child) {
    return child.getMembership(this.getOption('path'));
  }
}
