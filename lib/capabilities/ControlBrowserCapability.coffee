[Capability] = require('../Capability')
Q = require('q')

module.exports = class ControlBrowserCapability extends Capability
  name: "Control Browser"

  naturalCommands:
    on:
      forms: [
        'turn on <control>'
        'turn <control> on'
        'turn the <control> on'
        'turn on the <control>'
        'switch on <control>'
        'switch <control> on'
        'switch the <control> on'
        'switch on the <control>']
      resolve: (cap, {control}) ->
        control = cap.resolveControlName(control)
        if control?.hasCommand('turnOn') then {control: control} else null
      execute: (cap, {control}) ->
        d = Q.defer()
        control.executeCommand('turnOn')
          .fail -> d.reject  "Sorry, I couldn't turn it on."
          .then -> d.resolve "Okay, it's on."
        d.promise
    off:
      forms: [
        'turn off <control>'
        'turn <control> off'
        'turn the <control> off'
        'turn off the <control>'
        'switch off <control>'
        'switch <control> off'
        'switch the <control> off'
        'switch off the <control>']
      resolve: (cap, {control}) ->
        control = cap.resolveControlName(control)
        if control?.hasCommand('turnOff') then {control: control} else null
      execute: (cap, {control}) ->
        d = Q.defer()
        control.executeCommand('turnOff')
          .fail -> d.reject  "Sorry, I couldn't turn it off."
          .then -> d.resolve "Okay, it's off."
        d.promise

  start: ->
    # no-op server side
    @setValid true

  resolveControlName: (controlName) ->
    # XXX This should be much smarter
    controls = @_server.controls.select (control) ->
      control.get('name').toLowerCase() == controlName
    if controls.length == 1
      controls[0]
    else
      undefined