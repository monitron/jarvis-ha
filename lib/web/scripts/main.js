
require('babel-polyfill');

window.jarvis = {
  App: require('./App.coffee')
};

window.app = new jarvis.App();
