
_ = require('underscore')
Backbone = require('backbone')
uuid = require('uuid/v4')

# Event:
#  sourceType: 'capability', 'control', 'adapter'
#    sourceId: capability id, control id, etc.
#   reference: a string
#  importance: one of: routine, low, medium, high
#  start, end: Dates. end may be null
#       title: a short string
# description: a longer string, or null

class Event extends Backbone.Model
  initialize: ->
    unless @has('id') then @set 'id', uuid()

  isOngoing: ->
    !@has('end')

  isMomentary: ->
    @get('start') == @get('end')

class Events extends Backbone.Collection
  model: Event

  importances: ['high', 'medium', 'low', 'routine'] # in decreasing order

  ongoing: ->
    @filter (event) -> event.isOngoing()

  fromSource: (sourceType, sourceId, ongoingOnly = false) ->
    events = @where(sourceType: sourceType, sourceId: sourceId)
    if ongoingOnly then events = _.filter(events, (e) -> e.isOngoing())
    events

  greatestImportance: ->
    for imp in @importances
      if @findWhere(importance: imp) then return imp
    undefined


module.exports = [Event, Events]