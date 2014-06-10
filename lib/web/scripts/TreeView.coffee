
Backbone = require('backbone')
_ = require('underscore')

module.exports = class TreeView extends Backbone.View
  className: 'controlTree'

  render: ->
    @$el.html @renderChildren(@model)
    this

  renderChildren: (kids, path = []) ->
    $el = $("<ul></ul>")
    for name, elements of kids
      $li = $("<li></li>")
      subpath = path.concat(name)
      $li.append $("<a></a>").
        attr('href', '#path/' + subpath.join('/')).
        text(name)
      unless _.isEmpty(elements)
        $li.append @renderChildren(elements, subpath)
      $el.append $li
    $el