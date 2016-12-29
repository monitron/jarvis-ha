
_ = require('underscore')
Backbone = require('backbone')
uuid = require('uuid/v4')

# Event:
#  capability: capability id
#   reference: a string
#  importance: one of low, medium, high
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

  importances: ['high', 'medium', 'low'] # in decreasing order

  ongoing: ->
    @filter (event) -> event.isOngoing()

  fromCapability: (capability, ongoingOnly = false) ->
    events = @where(capability: capability)
    if ongoingOnly then events = _.filter(events, (e) -> e.isOngoing())
    events

  greatestImportance: ->
    for imp in @importances
      if @findWhere(importance: imp) then return imp
    undefined


module.exports = [Event, Events]