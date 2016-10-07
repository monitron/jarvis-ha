
const _ = require('underscore');
const Backbone = require("backbone");
const [Control, Controls] = require('./Control.coffee');
const [Capability, Capabilities] = require('./Capability.js');
const Router = require('./Router.js');
const AppView = require('./AppView.js');
const LocationPickerView = require('./location-picker/LocationPickerView.js');

module.exports = class App extends Backbone.Model {
  initialize() {
    this.log("Jarvis web client here");
    Backbone.$ = window.$;
    this.router = new Router({app: this});
    this.controls = new Controls();
    this.capabilities = new Capabilities();
    this.urlParams = new URLSearchParams(window.location.search);
    this.set('display', this.displayType());
    if(this.urlParams.has('station')) {
      this.set('station', this.urlParams.get('station'));
      this.log(`This station is called ${this.get('station')}`);
    }
    this.log(`Display type: ${this.get('display')}`);
    // TODO Detect orientation change and reset display type?

    // Do async startup tasks, then start app
    $.when(
      this.controls.fetch(),
      this.capabilities.fetch()
    ).then(this.start.bind(this));
  }

  start() {
    this.log('Startup tasks are finished');
    this.view = new AppView({
      model: this,
      display: this.get('display')
    });
    $('body').append(this.view.render().el);
    Backbone.history.start();
    this.setupSocket();
    // Default to first capability
    if(!this.has('capability'))
      this.set('capability', this.capabilities.first().id);
  }

  currentCapability() {
    if(this.has('capability')) {
      return this.capabilities.get(this.get('capability'));
    } else {
      return null;
    }
  }

  setupSocket() {
    this.socket = io();
    this.socket.on('connect', () => this.log('Socket connected'));
    this.socket.on('disconnect', () => this.log('Socket disconnected!'));
    this.socket.on('reconnect', () => this.log('Socket reconnected'));
    this.socket.on('reconnect-failed', () => this.log('Socket gave up reconnecting'));
    this.socket.on('control:change', (ctrldata) => {
      const control = this.controls.get(ctrldata.id);
      if(control == null) {
        this.log('warn', `Received update about unknown control ${ctrldata.id}`);
      } else {
        control.set(ctrldata);
      }
    });
  }

  pickLocation(callback, currentLoc = undefined) {
    const view = new LocationPickerView({
      callback: callback,
      current: currentLoc});
    this.view.showModalView('Choose Room', view);
  }

  displayType() {
    const $window = $(window);
    if(this.urlParams.has('display')) {
      return this.urlParams.get('display')
    } else if($window.width() <= 800 || $window.height() <= 450) {
      return 'phone';
    } else {
      return 'desktop';
    }
  }

  log(one, two) {
    if(two != null) {
      console.log(two);
    } else {
      console.log(one);
    }
  }
};
