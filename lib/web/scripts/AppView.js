
const _ = require('underscore');
const Marionette = require('backbone.marionette');
const ModalView = require('./ModalView.js');
const IdleView = require('./IdleView.js');
const navClasses = {
  touchscreen: require('./nav/TouchscreenNavView.js'),
  phone: require('./nav/PhoneNavView.js'),
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
      'touchstart': 'interceptTouches',
      'mousedown':  'resetIdleTimer'
    };
  }

  className() {
    return `app display-${this.getOption('display')}`;
  }

  initialize() {
    this.hasIdle = this.getOption('display') == 'touchscreen';
    // Debouncing touchstart handling has the intended effect of always
    // acting on the maximum number of touches (a 3 finger touch often comes
    // in as 1 first, then 2, then 3)
    this.debouncedMultiTouch = _.debounce(
      ((n) => this.handleMultiTouch(n)), 100);
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

  interceptTouches(ev) {
    const numTouches = ev.originalEvent.touches.length;
    if(numTouches > 1) {
      ev.preventDefault();
      this.debouncedMultiTouch(numTouches);
    } else {
      this.resetIdleTimer();
    }
  }

  // Call debouncedMultiTouch instead
  handleMultiTouch(numTouches) {
    const cfgKey = (numTouches == 2) ? 'twoTouchScene' : 'threeTouchScene';
    const scene = this.model.scenes.get(this.model.stationConfig.get(cfgKey));
    if(scene != null) scene.activate();
  }

  setIdle(state) {
    this.isIdle = state;
    this.resetIdleTimer();
    this.$el.toggleClass('is-idle', state);
  }
}
