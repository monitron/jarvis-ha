
const Backbone = require('backbone');

module.exports = class Router extends Backbone.Router {
  initialize(options) {
    this.app = options.app;
  }

  routes() {
    return {
      'capability/:id': 'capability',
      'scene/:id': 'scene'
    };
  }

  capability(id) {
    this.app.set('capability', id);
  }

  scene(id) {
    this.app.set('activate-scene', id);
  }
}
