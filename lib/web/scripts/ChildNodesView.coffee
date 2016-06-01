
Backbone = require('backbone')

module.exports = class ChildNodesView extends Backbone.View
  className: 'child-nodes'

  initialize: (options) ->
    @path = options.path

  render: ->
    context = subpaths: for subpath in @model
      name: subpath
      url:  "#path/" + @path.concat(subpath).join('/')
    @$el.html Templates['child-nodes'](context)
    this