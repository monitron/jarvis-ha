
const Marionette = require('backbone.marionette');
const ModalView = require('./ModalView.js');
const navClasses = {
  touchscreen: require('./nav/TouchscreenNavView.js'),
  phone: require('./nav/TouchscreenNavView.js'),
  desktop: require('./nav/DesktopNavView.js')
};

module.exports = class AppView extends Marionette.View {
  template = Templates['app'];

  modelEvents() {
    return {
      'change:capability': 'showBodyView'
    };
  }

  regions() {
    return {
      nav: '#nav',
      body: '#body',
      modal: '#modalContainer'
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
    const capability = this.model.currentCapability();
    if(capability != null) {
      const bodyClass = capability.view;
      this.showChildView('body', new bodyClass({model: capability}));
    }
  }

  showModalView(title, view) {
    const modalView = new ModalView({title: title, content: view});
    this.$el.addClass('with-modal');
    this.listenTo(modalView, 'destroy',
                  () => this.$el.removeClass('with-modal'));
    this.showChildView('modal', modalView);
  }
}
