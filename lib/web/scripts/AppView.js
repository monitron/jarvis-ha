
const Marionette = require('backbone.marionette');
const ModalView = require('./ModalView.js');
const IdleView = require('./IdleView.js');
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
      nav:   '#nav',
      body:  '#body',
      modal: '#modalContainer',
      idle:  '#idle'
    };
  }

  events() {
    return {
      'touchstart': 'resetIdleTimer',
      'mousedown':  'resetIdleTimer'
    };
  }

  className() {
    return `app display-${this.getOption('display')}`;
  }

  initialize() {
    this.hasIdle = this.getOption('display') == 'touchscreen';
  }

  onRender() {
    this.showNavView();
    this.showBodyView();
    this.showIdleView();
    if(this.hasIdle) this.setIdle(false);
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

  showIdleView() {
    const idleView = new IdleView({model: this.model});
    this.listenTo(idleView, 'hide', () => this.setIdle(false));
    this.showChildView('idle', idleView);
  }

  showModalView(title, view) {
    const modalView = new ModalView({title: title, content: view});
    this.$el.addClass('with-modal');
    this.listenTo(modalView, 'destroy',
                  () => this.$el.removeClass('with-modal'));
    this.showChildView('modal', modalView);
  }

  resetIdleTimer() {
    if(this.hasIdle && !this.isIdle) {
      if(this.idleTimer != null) clearTimeout(this.idleTimer);
      this.idleTimer = setTimeout(() => this.setIdle(true), 60000);
    }
  }

  setIdle(state) {
    this.isIdle = state;
    this.resetIdleTimer();
    this.$el.toggleClass('is-idle', state);
  }
}
