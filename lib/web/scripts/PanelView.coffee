
Backbone = require('backbone')
ControlView = require('./ControlView.coffee')

module.exports = class PanelView extends Backbone.View
  className: 'controlPanel'

  initialize: (options) ->
    @name = options.name
    @controlViews = for control in @model
      new ControlView(model: control)

  render: ->
    @$el.html Templates['panel'](name: @name)
    for controlView in @controlViews
      @$('.controls').append controlView.render().el
    this