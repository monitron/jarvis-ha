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

  start: ->
    # no-op server side
    @setValid true

  resolveControlName: (controlName) ->
    # XXX This should be much smarter
    controls = @_server.controls.select (control) ->
      _.contains(control.matchableNames(), controlName)
    if controls.length == 1 then controls[0] else undefined
