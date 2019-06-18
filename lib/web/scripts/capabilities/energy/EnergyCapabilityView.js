
const Marionette = require('backbone.marionette');

const MeterValuesView = require('./MeterValuesView.js');
const PagesView = require('../../PagesView.js');

module.exports = class EnergyCapabilityView extends Marionette.View {
  template = Templates['capabilities/energy/energy'];
  className() { return 'energy-capability'; }

  regions() {
    return {
      pages: '.energy-pages'
    };
  }

  onRender() {
    const pagesView = new PagesView({model: this.model, fullSize: true});
    this.showChildView('pages', pagesView);
  }
}
