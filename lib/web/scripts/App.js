
const Backbone = require("backbone");
const [Control, Controls] = require('./Control.coffee');
const [Capability, Capabilities] = require('./Capability.js');
const Router = require('./Router.coffee');
const AppView = require('./AppView.js');

module.exports = class App extends Backbone.Model {
  defaults() {
    return {display: 'touchscreen'};
  }
  
  initialize() {
    this.log("Jarvis web client here");
    Backbone.$ = window.$;
    this.router = new Router({app: this});
    this.controls = new Controls();
    this.capabilities = new Capabilities();
    // Do async startup tasks, then start app
    $.when([
      this.controls.fetch(),
      this.capabilities.fetch()
    ]).done(() => this.start());
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

  log(one, two) {
    if(two != null) {
      console.log(two);
    } else {
      console.log(one);
    }
  }
};
