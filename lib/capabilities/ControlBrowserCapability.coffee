_ = require('underscore')
Q = require('q')
[Capability] = require('../Capability')
[Consumption, Consumptions] = require('../Consumption')

module.exports = class ControlBrowserCapability extends Capability
  name: "Control Browser"

  defaults:
    pathAliases: []

  naturalCommands:
    on:
      forms: [
        '(turn|switch) on( the)? <control>'
        '(turn|switch)( the)? <control> on'
        '<control> on']
      resolve: (cap, {control}) ->
        control = cap.resolveControlName(control)
        if control?.hasCommand('turnOn') then {control: control} else null
      execute: (cap, {control}) ->
        d = Q.defer()
        control.executeCommand('turnOn')
          .fail -> d.reject  "Sorry, that didn't work."
          .then -> d.resolve "Okay, turned on."
        d.promise
    off:
      forms: [
        '(turn|switch|shut) off( the)? <control>'
        '(turn|switch|shut)( the)? <control> off'
        '<control> off']
      resolve: (cap, {control}) ->
        control = cap.resolveControlName(control)
        if control?.hasCommand('turnOff') then {control: control} else null
      execute: (cap, {control}) ->
        d = Q.defer()
        control.executeCommand('turnOff')
          .fail -> d.reject  "Sorry, that didn't work."
          .then -> d.resolve "Okay, turned off."
        d.promise
    offInCategory:
      forms: [
        '(turn|switch|shut) off( all| every)?( of)?( the)? <category>'
        '(turn|switch|shut)( all| every)?( the)? <category> off'
        '<category> off']
      resolve: (cap, {category}) ->
        path = cap.resolvePathName(category, ['category'])
        if path
          controls: cap.resolveControls([
            {type: 'valid'},
            {type: 'hasCommand', value: 'turnOff'},
            {type: 'memberOf', value: path}])
        else null
      execute: (cap, {controls}) ->
        d = Q.defer()
        controls = _.select(controls, (control) -> control.isActive())
        if _.isEmpty(controls)
          d.resolve "There is nothing on in that category."
        else
          Q.all(control.executeCommand('turnOff') for control in controls)
            .fail -> d.reject  "Sorry, that didn't work."
            .then -> d.resolve "Okay, turned off everything in that category."
        d.promise
    setDiscreteSpeed:
      forms: [
        '(set|turn|switch|put)( the)? <control> (to|on|at) <speed>'
        '(set|turn|switch|put)( the)? <control> (to|on|at) <speed> speed'
        '(set|turn|switch|put)( the)? <control> speed (to|on|at) <speed>'
        '(turn|switch|put) on( the)? <control> (to|at) <speed>'
        '(turn|switch|put) on( the)? <control> (to|at) <speed> speed'
        '(turn|switch|put)( the)? <control> on (to|at) <speed>'
        '(turn|switch|put)( the)? <control> on (to|at) <speed> speed'
        '<control> (on|to|at) <speed>'
        '<control> (on|to|at) <speed> speed']
      resolve: (cap, {control, speed}) ->
        control = cap.resolveControlName(control)
        if control?.hasCommand('setDiscreteSpeed')
          speedId = control.resolveSpeedName(speed)
          if speedId?
            {control: control, speed: speedId}
          else null
        else null
      execute: (cap, {control, speed}) ->
        d = Q.defer()
        control.executeCommand('setDiscreteSpeed', value: speed)
          .fail -> d.reject  "Sorry, that didn't work."
          .then -> d.resolve "Okay, speed set."
        d.promise
    lock:
      forms: [
        'lock( the)? <control>']
      resolve: (cap, {control}) ->
        control = cap.resolveControlName(control)
        if control?.hasCommand('lock') then {control: control} else null
      execute: (cap, {control}) ->
        d = Q.defer()
        control.executeCommand('lock')
          .fail -> d.reject  "Sorry, that didn't work."
          .then -> d.resolve "Okay, locked."
        d.promise
    unlock:
      forms: [
        'unlock( the)? <control>']
      resolve: (cap, {control}) ->
        control = cap.resolveControlName(control)
        if control?.hasCommand('unlock') then {control: control} else null
      execute: (cap, {control}) ->
        d = Q.defer()
        control.executeCommand('unlock')
          .fail -> d.reject  "Sorry, that didn't work."
          .then -> d.resolve "Okay, unlocked."
        d.promise
    status:
      forms: [
        "(what is |describe |report )?(the )?(status|state) of( the)? <control>",
        "(what is |describe |report )?(the )?<control> (status|state)",
        '(is|are)( the)? <control> (turned |switched |shut )?(on|off|open|closed|locked|unlocked)']
      resolve: (cap, {control}) ->
        control = cap.resolveControlName(control)
        if control? then {control: control} else null
      execute: (cap, {control}) ->
        Q.fcall => "#{control.get('name')} is #{control.describeCurrentState()}"
    whatIsOn:
      forms: [
        "is anything( turned| switched)? on",
        "are( there)? any devices( turned| switched)? on",
        "what is( turned| switched)? on",
        "(control|device)(s)? status"]
      resolve: (cap) ->
        controls: cap.resolveControls([
          {type: 'valid'},
          {type: 'active'},
          {type: 'hasCommand', value: 'turnOff'}])
      execute: (cap, {controls}) ->
        list = if _.isEmpty(controls)
          "Nothing"
        else
          cap.formatNaturalList(_.map(controls, (c) -> c.get('name')))
        verb = if controls.length > 2 then 'are' else 'is'
        Q.fcall -> "#{list} #{verb} on."
    whatIsOnInCategory:
      forms: [
        "are( there)? any <category> on",
        "are( there)? any <category> (turned|switched) on",
        "(what|which) <category> are( turned| switched)? on",
        "<category> status"]
      resolve: (cap, {category}) ->
        path = cap.resolvePathName(category, ['category'])
        if path
          controls: cap.resolveControls([
            {type: 'valid'},
            {type: 'active'},
            {type: 'hasCommand', value: 'turnOff'},
            {type: 'memberOf', value: path}])
        else null
      execute: (cap, {controls}) ->
        list = if _.isEmpty(controls)
          "Nothing in that category"
        else
          cap.formatNaturalList(_.map(controls, (c) -> c.get('name')))
        verb = if controls.length > 2 then 'are' else 'is'
        Q.fcall -> "#{list} #{verb} on."

  start: ->
    @listenTo @_server.controls, 'change', =>
      @trigger 'consumption:change', this
    @setValid true

  resolveControlName: (controlName) ->
    # XXX This should be much smarter
    controls = @_server.controls.select (control) ->
      _.contains(control.matchableNames(), controlName)
    if controls.length == 1 then controls[0] else undefined

  resolvePathName: (name, prefix = []) ->
    paths = _.select @get('pathAliases'), (alias) ->
      _.isEqual(alias.path.slice(0, prefix.length), prefix) and
        _.contains(alias.names, name)
    if paths.length == 1 then paths[0].path else undefined

  resolveControls: (filters) ->
    @_server.controls.selectWithFilters(filters)

  getResourceConsumption: ->
    consumptions = new Consumptions()
    getControlCategory = (control) =>
      path = control.getDefaultMembershipPath(['category'])
      if path? then _.last(path) else 'Other'
    @_server.controls.each (control) =>
      rates = control.getConsumptionRates()
      if rates?
        for resource, rate of rates when rate > 0
          consumptions.add
            capabilityId: @id
            node: control.id
            name: control.get('name')
            category: getControlCategory(control)
            resourceType: resource
            rate: rate
    consumptions
