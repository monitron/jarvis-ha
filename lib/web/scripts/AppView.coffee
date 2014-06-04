
Backbone = require('backbone')

module.exports = class AppView extends Backbone.View
  render: ->
    @$el.html Templates['app']()