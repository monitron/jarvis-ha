
const Backbone = require("backbone");
const [Control, Controls] = require('./Control.coffee');
const Router = require('./Router.coffee');
const AppView = require('./AppView.coffee');

module.exports = class App extends Backbone.Model {
  initialize() {
    this.log("Jarvis web client here");
    Backbone.$ = window.$;
    this.router = new Router({app: this});
    this.controls = new Controls();
    // Do async startup tasks, then start app
    this.controls.fetch().done(() => this.start());
  }

  start() {
    this.log('Startup tasks are finished');
    this.view = new AppView({el: $('body'), model: this});
    this.view.render();
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
