_ = require('underscore')
[baseControl, baseControls] = require('../../Control.coffee')

class Control extends baseControl
  initialize: ->
    super
    @_tasks = []

  addTask: (promise) ->
    @_tasks.push promise
    @trigger 'task:started'
    if @_tasks.length == 1 then @trigger 'task:some'
    promise.done => @trigger 'task:done', promise
    promise.fail => @trigger 'task:fail', promise
    promise.always =>
      @_tasks = _.without(@_tasks, promise)
      if _.isEmpty(@_tasks) then @trigger 'task:none'

  isActive: ->
    @get('active')

  hasCommand: (verb) ->
    _.contains(@get('commands'), verb)

  isBusy: ->
    !_.isEmpty(@_tasks)

  sendCommand: (commandId, params = {}) ->
    promise = $.ajax
      url: "api/controls/#{@id}/commands/#{commandId}"
      type: 'POST'
      data: params
    @addTask promise
    promise

class Controls extends baseControls
  model: Control
  url: 'api/controls'

module.exports = [Control, Controls]
