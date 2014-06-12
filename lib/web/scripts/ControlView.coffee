
Backbone = require('backbone')
controlBodyViews = require('./controls/index.coffee')

module.exports = class ControlView extends Backbone.View
  tagName: 'li'
  className: 'col-md-6'

  initialize: ->
    bodyViewClass = controlBodyViews[@model.control.get('type')]
    if bodyViewClass?
      @bodyView = new bodyViewClass(model: @model.control)

  render: ->
    context =
      name: @model.control.get('name')
    @$el.html Templates['control'](context)
    if @bodyView?
      @$('.body').html @bodyView.render().el
    else
      @$('.body').text "(Missing control body view for: #{@model.control.get('type')})"
    this