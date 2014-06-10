
Backbone = require('backbone')

module.exports = class Router extends Backbone.Router
  initialize: (options) ->
    @app = options.app

  routes:
    "path/*path": "path"

  path: (path) ->
    @app.set 'path', path.split("/")