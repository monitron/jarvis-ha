
Backbone = require('backbone')
util = require('../util.coffee')
d3 = require('d3')
_ = require('underscore')

module.exports = class ThermostatControlBodyView extends Backbone.View
  events:
    'click .incrButton': 'increaseTemp'
    'click .decrButton': 'decreaseTemp'

  render: ->
    context = @formattedValues()
    @$el.html Templates['controls/thermostat'](context)
    this

  formattedValues: ->
    state = _.clone(@model.get('state'))
    params = @model.get('parameters')
    if state.targetTemperature?
      if params.temperatureUnits == 'f'
        state.targetTemperature = util.tempToFahrenheit(state.targetTemperature)
      formatter = d3.format(".#{params.temperaturePrecision}f")
      state.targetTemperature = formatter(state.targetTemperature)
    if state.mode? then state.mode = state.modeChoices[state.mode]
    state.isOn = !(state.mode == 'off')
    state

  increaseTemp: ->
    @sendRelativeTempCommand(1)

  decreaseTemp: ->
    @sendRelativeTempCommand(-1)

  sendRelativeTempCommand: (offset) ->
    temp = @model.get('state').targetTemperature
    return unless temp?
    if @model.get('parameters').temperatureUnits == 'f'
      offset = offset * (5 / 9.0)
    @model.sendCommand 'setTarget', {value: temp + offset}