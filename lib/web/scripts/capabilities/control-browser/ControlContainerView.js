
const Marionette = require('backbone.marionette');
const controlBodyViews = require('../../controls/index.coffee')

module.exports = class ControlContainerView extends Marionette.View {
  template = Templates['capabilities/control-browser/control-container'];

  className() {
    const classes = ['control-container'];
    if(this.model.isActive()) classes.push('active');
    return classes.join(' ');
  }

  modelEvents() {
    return {
      'change:active': 'onActiveChange'
    };
  }

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

  onActiveChange() {
    this.$el.attr('class', this.className());
  }
}
