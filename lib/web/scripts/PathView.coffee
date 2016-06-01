
Backbone = require('backbone')

module.exports = class PathView extends Backbone.View
  tagName: 'ul'
  className: 'path'

  initialize: ->
    @listenTo @model, 'change:path', @render

  render: ->
    path = @model.get('path')
    subpaths = if path?.length > 2
      path.slice(n, -1) for n in [1..path.length - 2]
    else
      []
    context =
      subpaths: for subpath in subpaths
        url:  "#path/location/" + subpath.join('/')
        name: subpath.slice(-1)
      here: path?.slice(1).slice(-1) or null
    @$el.html Templates['path'](context)
    this