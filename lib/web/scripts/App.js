
const _ = require('underscore');
const Backbone = require("backbone");
const [Control, Controls] = require('./Control.coffee');
const [Capability, Capabilities] = require('./Capability.js');
const Router = require('./Router.js');
const AppView = require('./AppView.js');
const LocationPickerView = require('./location-picker/LocationPickerView.js');

module.exports = class App extends Backbone.Model {
  defaults() {
    return {display: 'phone'};
  }
  
  initialize() {
    this.log("Jarvis web client here");
    Backbone.$ = window.$;
    this.router = new Router({app: this});
    this.controls = new Controls();
    this.capabilities = new Capabilities();
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

  log(one, two) {
    if(two != null) {
      console.log(two);
    } else {
      console.log(one);
    }
  }
};
