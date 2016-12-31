
[SecurityRule] = require('../SecurityRule')

module.exports = class OpenSecurityRule extends SecurityRule
  defaultParameters:
    name:         'A door'
    presentTitle: '<%= name %> is open'
    pastTitle:    '<%= name %> was open'
    unknownTitle: '<%= name %> open/closed status is unknown'
    normallyOpen: false

  initialize: ->
    super
    @listenTo this, 'mode:change connection:change', @evaluate

  state: ->
    sensor = @getConnectionTarget('openCloseSensor')
    value = sensor.getAspect('openCloseSensor').getDatum('state')
    if !value?
      null
    else if @get('parameters').normallyOpen
      !value
    else
      value
