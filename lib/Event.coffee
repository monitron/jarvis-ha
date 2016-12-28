
Backbone = require('backbone')

# Event:
#  capability: capability id
#   reference: a string
#  importance: one of low, medium, high
#  start, end: Dates. end may be null
#       title: a short string
# description: a longer string, or null

class Event extends Backbone.Model
  isOngoing: ->
    !@has('end')

  isMomentary: ->
    @get('start') == @get('end')

class Events extends Backbone.Collection
  model: Event

  ongoing: ->
    @filter (event) -> event.isOngoing()

  fromCapability: (capability, ongoingOnly = false) ->
    events = @where(capability: capability)
    if ongoingOnly then events = _.filter(events, (e) -> e.isOngoing())
    events


module.exports = [Event, Events]