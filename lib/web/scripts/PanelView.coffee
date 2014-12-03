
Backbone = require('backbone')
ControlView = require('./ControlView.coffee')

module.exports = class PanelView extends Backbone.View
  className: 'controlPanel'

  initialize: (options) ->
    @name = options.name
    @controlViews = for cm in @model when cm.control.get('valid')
      new ControlView(model: cm)

  render: ->
    @$el.html Templates['panel'](name: @name)
    for controlView in @controlViews
      @$('.controls').append controlView.render().el
    this