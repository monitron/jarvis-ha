
Backbone = require('backbone')
ControlView = require('./ControlView.coffee')

module.exports = class PanelView extends Backbone.View
  className: 'controlPanel'

  initialize: ->
    @controlViews = for control in @model
      new ControlView(model: control)

  render: ->
    @$el.html Templates['panel']()
    for controlView in @controlViews
      @$('.controls').append controlView.render().el
    this