
_ = require('underscore')
Backbone = require('backbone')
TreeView = require('./TreeView.coffee')
PathView = require('./PathView.coffee')
PanelView = require('./PanelView.coffee')

module.exports = class AppView extends Backbone.View
  initialize: ->
    @treeView = new TreeView(model: @model.controls.getPathTree())
    @pathView = new PathView(model: @model)
    @listenTo @model, 'change:path', @renderPath

  render: ->
    @$el.html Templates['app']()
    @$('.sidebar').append @treeView.render().el
    @$('.breadcrumbs').append @pathView.render().el
    @renderPath()

  renderPath: ->
    @panelView?.remove()
    delete @panelView
    path = @model.get('path')
    if path?
      members = @model.controls.findMembersOfPath(path)
      @panelView = new PanelView
        model: members
        path: path
        subpaths: @model.controls.findSubpathsOfPath(path)
      @$('.body').html @panelView.render().el
