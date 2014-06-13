
Backbone = require('backbone')
util = require('../util.coffee')
d3 = require('d3')
_ = require('underscore')

module.exports = class ClimateSensorControlBodyView extends Backbone.View
  render: ->
    context = @formattedValues()
    @$el.html Templates['controls/climateSensor'](context)
    this

  formattedValues: ->
    state = _.clone(@model.get('state'))
    params = @model.get('parameters')
    if state.temperature?
      if params.temperatureUnits == 'f'
        state.temperature = util.tempToFahrenheit(state.temperature)
      formatter = d3.format(".#{params.temperaturePrecision}f")
      state.temperature = formatter(state.temperature)
    if state.humidity?
      formatter = d3.format(".#{params.humidityPrecision}f")
      state.humidity = formatter(state.humidity)
    state
