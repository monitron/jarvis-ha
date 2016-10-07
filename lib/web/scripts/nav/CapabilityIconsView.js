
const Marionette = require('backbone.marionette');
const CapabilityIconView = require('./CapabilityIconView.js');

module.exports = class CapabilityIconsView extends Marionette.CollectionView {
  childView = CapabilityIconView;

  modelEvents() {
    return {
      'change:capability': 'render'
    };
  }

  childViewOptions(model, index) {
    return {
      selected: this.model.get('capability') == model.id
    };
  }
}
