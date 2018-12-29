
const _ = require('underscore');
const Backbone = require("backbone");
const moment = require('moment');
const [Control, Controls] = require('./Control.coffee');
const [Capability, Capabilities] = require('./Capability.js');
const [Scene, Scenes] = require('./Scene.js');
const [Event, Events] = require('./Event.js');
const [Card, Cards] = require('./Card.js');
const StationConfig = require('./StationConfig.js');
const Router = require('./Router.js');
const AppView = require('./AppView.js');
const LocationPickerView = require('./picker/LocationPickerView.js');
const GenericPickerView = require('./picker/GenericPickerView.js');
const EventBrowser = require('./events/EventBrowser.js');
const PagesView = require('./PagesView.js');
const DebugView = require('./DebugView.js');
const ActivateSceneView = require('./ActivateSceneView.js');
const Conversation = require('./conversation/Conversation.js');
const ConversationView = require('./conversation/ConversationView.js');

module.exports = class App extends Backbone.Model {
  defaults() {
    return {
      'sync-state': 'new' // states: syncing, synced, disconnected
    };
  }
  
  initialize() {
    this.logBuffer = [];
    window.onerror = (m, u, l, c, e) => this.globalErrorHandler(m, e);
    $(document).ajaxError((e, x, s, t) => this.log(`XHR failed (${s.url}): ${t}`));
    this.log("Jarvis web client here");
    $.ajaxSetup({cache: false}); // Append timestamps to GET XHRs
    Backbone.$ = window.$;
    this.router = new Router({app: this});
    this.controls = new Controls();
    this.capabilities = new Capabilities();
    this.scenes = new Scenes();
    this.events = new Events();
    this.cards = new Cards();
    this.urlParams = new URLSearchParams(window.location.search);
    this.eventBrowser = new EventBrowser();
    this.conversation = new Conversation();
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
    } else {
      this.stationConfig = new StationConfig();
    }
    this.log(`Display type: ${this.get('display')}`);
    // TODO Detect orientation change and reset display type?

    // Do initial daya sync, then start app
    this.syncAnd(startCallback);
  }

  start() {
    this.log('Startup tasks are finished');
    // Default to first capability
    if(!this.has('capability'))
      this.set('capability', this.capabilities.first().id);
    Backbone.history.start();
    if(this.has('activate-scene')) {
      this.activateScene();
    } else {
      this.view = new AppView({
        model: this,
        display: this.get('display')
      });
      $('body').append(this.view.render().el);
      this.setupSocket();
      $(document).on('visibilitychange', this.onVisibilityChange.bind(this));
      // Set up a watchdog to notice if a lot of time gets skipped
      setInterval(this.watchdog.bind(this), 1000);
    }
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
    this.socket.on('events:change', (events) => {
      this.events.reset(events);
    });
  }

  pickLocation(callback, currentLoc = undefined) {
    const view = new LocationPickerView({
      callback: callback,
      current: currentLoc});
    this.view.showModalView('Choose Room', view);
  }

  pick(callback, name, choices, current = undefined) {
    const view = new GenericPickerView({
      callback: callback,
      current: current,
      choices: choices
    });
    this.view.showModalView(name, view, {width: '450px'});
  }

  displayEvents() {
    this.eventBrowser.set('page', 'ongoing');
    const view = new PagesView({model: this.eventBrowser, fullSize: true});
    this.view.showModalView('Notifications', view);
  }

  showDebug() {
    const view = new DebugView({model: this});
    this.view.showModalView('Debug', view);
  }

  showConversation() {
    const view = new ConversationView({model: this.conversation});
    this.view.showModalView('Conversation', view, {width: '450px'});
  }

  activateScene() {
    const scene = this.scenes.get(this.get('activate-scene'));
    const promise = scene.activate();
    promise.always(() => this.router.navigate('scene-activation-done'));
    const view = new ActivateSceneView({
      model: scene,
      promise: promise
    });
    $('body').append(view.render().el);
  }

  visitCapability(id) {
    if(this.get('capability') != id) {
      this.view.hideAnyModalView();
      this.router.navigate(`capability/${id}`, {trigger: true});
    }
  }
  
  visitControl(id) {
    this.visitCapability('controlBrowser');
    this.currentCapability().visitControl(id);
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
        this.syncAnd(() => {
          this.log('Finished resync due to watchdog.');
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
    if(this.get('sync-state') !== 'syncing') {
      this.log('Regained connection. Requesting full updates.');
      this.syncAnd(() => {
        this.log('Finished resync due to reconnection.');
      });
    }
  }

  onVisibilityChange() {
    if(!document.hidden && this.get('sync-state') !== 'syncing') {
      this.log('Was nonvisible; now visible again. Requesting full updates.');
      this.syncAnd(() => {
        this.log('Finished resync due to visibility.');
      });
    }
  }

  syncAnd(callback) {
    this.set('sync-state', 'syncing');
    $.when(
      this.controls.fetch(),
      this.capabilities.fetch(),
      this.events.fetch(),
      this.scenes.fetch())
      .fail(() => {
        this.log('Sync failed. Scheduling another attempt.');
        setTimeout(() => this.syncAnd(callback), 1000);
      })
      .then(() => { this.set('sync-state', 'synced'); callback(); });
  }

  idleViews() {
    return _.flatten(this.capabilities.map(
      (cap) => _.map(cap.idleViews || [], (v) => [cap, v])), true);
  }

  isDark() {
//    return true;
    const hour = (new Date()).getHours();
    return hour < this.stationConfig.get('darkEndHour') ||
      hour >= this.stationConfig.get('darkStartHour');
  }

  globalErrorHandler(msg, errorObj) {
    const buffer = msg;
    if(errorObj != null && _.isString(errorObj.stack)) {
      msg += '<br><br>' + errorObj.stack.replace(/\n/g, "<br>");
    }
    this.log(msg);
  }

  log(one, two) {
    const msg = (two != null) ? two : one;
    console.log(msg);
    this.logBuffer.push(`${moment().format('HH:mm:ss')} ${msg}`);
  }
};
