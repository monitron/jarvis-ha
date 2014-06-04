
Backbone = require('backbone')
Control = require('./Control.coffee')

module.exports = class Controls extends Backbone.Collection
  model: Control
  url: '/api/controls'