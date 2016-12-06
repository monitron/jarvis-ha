
const _ = require('underscore');
const Backbone = require("backbone");
const moment = require('moment');
const [Control, Controls] = require('./Control.coffee');
const [Capability, Capabilities] = require('./Capability.js');
const [Scene, Scenes] = require('./Scene.js');
const StationConfig = require('./StationConfig.js');
const Router = require('./Router.js');
const AppView = require('./AppView.js');
const LocationPickerView = require('./location-picker/LocationPickerView.js');
const DebugView = require('./DebugView.js');

module.exports = class App extends Backbone.Model {
  defaults() {
    return {
      'sync-state': 'new' // states: syncing, synced, disconnected
    };
  }
  
  initialize() {
    this.logBuffer = [];
    this.log("Jarvis web client here");
    $.ajaxSetup({cache: false}); // Append timestamps to GET XHRs
    Backbone.$ = window.$;
    this.router = new Router({app: this});
    this.controls = new Controls();
    this.capabilities = new Capabilities();
    this.scenes = new Scenes();
    this.urlParams = new URLSearchParams(window.location.search);
    this.set('display', this.displayType());
    let startCallback = this.start.bind(this);
    if(this.urlParams.has('station')) {
      this.set('station', this.urlParams.get('station'));
      this.stationConfig = new StationConfig({id: this.get('station')});
      this.log(`This station is called ${this.get('station')}`);
      let prevStartCallback = startCallback;
      startCallback = (function() {
        this.stationConfig.fetch().then(prevStartCallback);
      }).bind(this);
    }
    this.log(`Display type: ${this.get('display')}`);
    // TODO Detect orientation change and reset display type?

    // Do initial daya sync, then start app
    this.set('sync-state', 'syncing');
    this.syncAnd(startCallback);
  }

  start() {
    this.log('Startup tasks are finished');
    this.set('sync-state', 'synced');
    this.view = new AppView({
      model: this,
      display: this.get('display')
    });
    $('body').append(this.view.render().el);
    Backbone.history.start();
    this.setupSocket();
    $(document).on('visibilitychange', this.onVisibilityChange.bind(this));
    // Default to first capability
    if(!this.has('capability'))
      this.set('capability', this.capabilities.first().id);
    // Set up a watchdog to notice if a lot of time gets skipped
    setInterval(this.watchdog.bind(this), 1000);
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
    this.socket.on('connect', () => this.onConnect());
    this.socket.on('disconnect', () => this.onDisconnect());
    this.socket.on('reconnect', () => this.onReconnect());
    this.socket.on('reconnect-failed', () => this.log('Socket gave up reconnecting'));
    this.socket.on('control:change', (ctrldata) => {
      const control = this.controls.get(ctrldata.id);
      if(control == null) {
        this.log('warn', `Received update about unknown control ${ctrldata.id}`);
      } else {
        control.set(ctrldata);
      }
    });
    this.socket.on('capability:change', (capdata) => {
      const capability = this.capabilities.get(capdata.id);
      if(capability == null) {
        this.log('warn', `Received update about unknown capability ${capdata.id}`);
      } else {
        capability.set(capdata);
      }
    });
  }

  pickLocation(callback, currentLoc = undefined) {
    const view = new LocationPickerView({
      callback: callback,
      current: currentLoc});
    this.view.showModalView('Choose Room', view);
  }

  showDebug() {
    const view = new DebugView({model: this});
    this.view.showModalView('Debug', view);
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

  watchdog() {
    const now = new Date();
    if(this.prevWatchdogTime != null) {
      if(now - this.prevWatchdogTime > 5000 &&
         this.get('sync-state') !== 'syncing') {
        this.log("Didn't run for a long time. Requesting full updates.");
        this.set('sync-state', 'syncing');
        this.syncAnd(() => {
          this.log('Finished resync due to watchdog.');
          this.set('sync-state', 'synced');
        });
      }
    }
    this.prevWatchdogTime = now;
  }

  onConnect() {
    this.log('Socket connected');
    // If this is the inital connection, we JUST fetched everything.
    // If it isn't, the reconnect handler will handle resyncing
    if(this.get('sync-state') === 'new') this.set('sync-state', 'synced');
  }

  onDisconnect() {
    this.log('Socket disconnected!');
    this.set('sync-state', 'disconnected');
  }

  onReconnect() {
    this.log('Regained connection. Requesting full updates.');
    this.set('sync-state', 'syncing');
    this.syncAnd(() => {
      this.log('Finished resync due to reconnection.');
      this.set('sync-state', 'synced');
    });
  }

  onVisibilityChange() {
    if(!document.hidden && this.get('sync-state') !== 'syncing') {
      this.log('Was nonvisible; now visible again. Requesting full updates.');
      this.set('sync-state', 'syncing');
      this.syncAnd(() => {
        this.log('Finished resync due to visibility.');
        this.set('sync-state', 'synced');
      });
    }
  }

  syncAnd(callback) {
    this.set('sync-state', 'syncing');
    $.when(
      this.controls.fetch(),
      this.capabilities.fetch(),
      this.scenes.fetch()
    ).then(callback);
  }

  capabilitiesWithIdleViews() {
    return this.capabilities.select((cap) => cap.idleView != null);
  }

  log(one, two) {
    const msg = (two != null) ? two : one;
    console.log(msg);
    this.logBuffer.push(`${moment().format('HH:mm:ss')} ${msg}`);
  }
};
