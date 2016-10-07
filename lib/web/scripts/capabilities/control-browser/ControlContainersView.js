
const Marionette = require('backbone.marionette');
const ControlContainerView = require('./ControlContainerView.js');

module.exports = class ControlContainersView extends Marionette.CollectionView {
  childView = ControlContainerView;

  filter(child, index, collection) {
    return child.getMembership(this.getOption('path')) != null &&
      child.get('valid');
  }
}
