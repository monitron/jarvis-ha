
Backbone = require('backbone')
TreeView = require('./TreeView.coffee')
PanelView = require('./PanelView.coffee')

module.exports = class AppView extends Backbone.View
  initialize: ->
    @treeView = new TreeView(model: @model.controls.getPathTree())
    @listenTo @model, 'change:path', @renderPath

  render: ->
    @$el.html Templates['app']()
    @$('.sidebar').html @treeView.render().el
    @renderPath()

  renderPath: ->
    @panelView?.remove()
    delete @panelView
    path = @model.get('path')
    if path?
      members = @model.controls.findMembersOfPath(path)
      @panelView = new PanelView(model: members)
      @$('.body').html @panelView.render().el
