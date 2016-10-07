
const Backbone = require('backbone');

module.exports = class Router extends Backbone.Router {
  initialize(options) {
    this.app = options.app;
  }

  routes() {
    return {
      'capability/:id': 'capability'
    };
  }

  capability(id) {
    this.app.set('capability', id);
  }
}
