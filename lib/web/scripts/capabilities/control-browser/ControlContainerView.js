
const Marionette = require('backbone.marionette');
const ControlDetails = require('./details/ControlDetails.js');
const PagesView = require('../../PagesView.js');
const controlBodyViews = require('../../controls/index.coffee');

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

  ui() {
    return {
      details: '.details'
    };
  }

  events() {
    return {
      'click @ui.details': 'onClickDetails'
    };
  }

  serializeData() {
    return {
      name: this.options.membership.name || this.model.get('name')
    };
  }
  
  onRender() {
    this.$el.attr('data-id', this.model.id);
    const bodyClass = controlBodyViews[this.model.get('type')];
    this.showChildView('body', new bodyClass({model: this.model}));
  }

  onClickDetails() {
    const model = new ControlDetails({control: this.model});
    const view = new PagesView({model: model, fullSize: true});
    window.app.view.showModalView(this.model.get('name'), view);
  }

  renderClasses() {
    this.$el.attr('class', this.className());
  }
}
