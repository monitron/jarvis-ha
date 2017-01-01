
const Marionette = require('backbone.marionette');
const controlBodyViews = require('../../controls/index.coffee')

module.exports = class ControlContainerView extends Marionette.View {
  template = Templates['capabilities/control-browser/control-container'];

  className() {
    const classes = ['control-container'];
    if(this.model.isActive()) classes.push('active');
    if(this.model.isBusy()) classes.push('busy');
    return classes.join(' ');
  }

  modelEvents() {
    return {
      'change:active': 'renderClasses',
      'task:some':     'renderClasses',
      'task:none':     'renderClasses'
    };
  }

  regions() {
    return {
      body: '.control-body'
    };
  }

  serializeData() {
    return {
      name: this.options.membership.name || this.model.get('name')
    };
  }
  
  onRender() {
    const bodyClass = controlBodyViews[this.model.get('type')];
    this.showChildView('body', new bodyClass({model: this.model}));
  }

  renderClasses() {
    this.$el.attr('class', this.className());
  }
}
