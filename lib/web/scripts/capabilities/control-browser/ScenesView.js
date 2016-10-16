
const Marionette = require('backbone.marionette');
const SceneView = require('./SceneView.js');

module.exports = class ScenesView extends Marionette.CollectionView {
  childView = SceneView;

  className() { return 'scenes-list'; }

  filter(child, index, collection) {
    return child.getMembership(this.getOption('path')) != null &&
      child.get('valid');
  }

  childViewOptions(model, index) {
    return {
      membership: model.getMembership(this.getOption('path'))
    };
  }
}
