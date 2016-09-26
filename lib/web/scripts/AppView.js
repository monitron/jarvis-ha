
const Marionette = require('backbone.marionette');
const navClasses = {
  touchscreen: require('./nav/TouchscreenNavView.js')
};

module.exports = class AppView extends Marionette.View {
  template = Templates['app'];

  regions() {
    return {
      nav: '#nav',
      body: '#body'
    };
  }

  className() {
    return `app display-${this.getOption('display')}`;
  }

  onRender() {
    this.showNavView();
    this.showBodyView();
  }

  showNavView() {
    const navClass = navClasses[this.model.get('display')];
    this.showChildView('nav', new navClass({model: this.model}));
  }

  showBodyView() {
  }
}
