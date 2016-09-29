
const Marionette = require('backbone.marionette');
const controlBodyViews = require('../../controls/index.coffee')

module.exports = class ControlContainerView extends Marionette.View {
  template = Templates['capabilities/control-browser/control-container'];

  className() { return 'control-container'; }

  regions() {
    return {
      body: '.control-body'
    };
  }

  serializeData() {
    return {
      name: this.model.get('name')
    };
  }
  
  onRender() {
    const bodyClass = controlBodyViews[this.model.get('type')];
    this.showChildView('body', new bodyClass({model: this.model}));
  }
}
