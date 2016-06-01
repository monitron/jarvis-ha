
_ = require('underscore')
Backbone = require('backbone')
ControlView = require('./ControlView.coffee')
ChildNodesView = require('./ChildNodesView.coffee')

module.exports = class PanelView extends Backbone.View
  className: 'controlPanel'

  initialize: (options) ->
    @name = _.last(options.path)
    @controlViews = for cm in @model when cm.control.get('valid')
      new ControlView(model: cm)
    @childNodesView = new ChildNodesView
      model: options.subpaths
      path: options.path

  render: ->
    @$el.html Templates['panel'](name: @name)
    for controlView in @controlViews
      @$('.controls').append controlView.render().el
    @$('.node-nav').append @childNodesView.render().el
    this