
require('babel-polyfill');

window.jarvis = {
  App: require('./App.js')
};

window.app = new jarvis.App();
