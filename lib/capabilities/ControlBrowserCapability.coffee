_ = require('underscore')
Q = require('q')
[Capability] = require('../Capability')

module.exports = class ControlBrowserCapability extends Capability
  name: "Control Browser"

  naturalCommands:
    on:
      forms: [
        '(turn|switch) on( the)? <control>'
        '(turn|switch)( the)? <control> on']
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
        '(turn|switch|shut)( the)? <control> off']
      resolve: (cap, {control}) ->
        control = cap.resolveControlName(control)
        if control?.hasCommand('turnOff') then {control: control} else null
      execute: (cap, {control}) ->
        d = Q.defer()
        control.executeCommand('turnOff')
          .fail -> d.reject  "Sorry, that didn't work."
          .then -> d.resolve "Okay, turned off."
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
        "(what is |what's |describe |report )?(the )?(status|state) of( the)? <control>",
        "(what is |what's |describe |report )?(the )?<control> (status|state)",
        '(is|are)( the)? <control> (turned |switched |shut )?(on|off|open|closed|locked|unlocked)']
      resolve: (cap, {control}) ->
        control = cap.resolveControlName(control)
        if control? then {control: control} else null
      execute: (cap, {control}) ->
        Q.fcall => "#{control.get('name')} is #{control.describeCurrentState()}"
    whatIsOn:
      forms: [
        "is anything on",
        "are( there)? any devices on",
        "(what's|what is)( turned| switched)? on",
        "control(s)? status"]
      resolve: (cap) ->
        controls: cap.resolveControls([{type: 'valid'}, {type: 'offable'}])
      execute: (cap, {controls}) ->
        list = if _.isEmpty(controls)
          "Nothing"
        else
          cap.formatNaturalList(_.map(controls, (c) -> c.get('name')))
        verb = if controls.length > 2 then 'are' else 'is'
        Q.fcall -> "#{list} #{verb} on."

  start: ->
    # no-op server side
    @setValid true

  resolveControlName: (controlName) ->
    # XXX This should be much smarter
    controls = @_server.controls.select (control) ->
      _.contains(control.matchableNames(), controlName)
    if controls.length == 1 then controls[0] else undefined

  resolveControls: (filters) ->
    @_server.controls.select (ctrl) ->
      for filter in filters
        result = switch filter.type
          when 'valid'   then ctrl.isValid()
          when 'offable' then ctrl.isActive() and ctrl.hasCommand('turnOff')
        return false unless result
      true
