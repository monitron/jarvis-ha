
const Marionette = require('backbone.marionette');
const controlBodyViews = require('../../controls/index.coffee')

module.exports = class SensorsView extends Marionette.CollectionView {
  className() { return 'sensors-list'; }

  childView(item) {
    return controlBodyViews[item.get('type')];
  }

  filter(child, index, collection) {
    const membership = child.getMembership(this.getOption('path'));
    return membership != null && child.get('context') === 'sensors' &&
      child.get('valid');
  }
}
