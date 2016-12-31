[SecurityRule] = require('../SecurityRule')

module.exports = class LockSecurityRule extends SecurityRule
  defaultParameters:
    name:           'A lock'
    presentTitle:   '<%= name %> is unlocked'
    pastTitle:      '<%= name %> was unlocked'
    unknownTitle:   '<%= name %> lock status is unknown'
    normallyLocked: false

  initialize: ->
    super
    @listenTo this, 'mode:change connection:change', @evaluate

  state: ->
    sensor = @getConnectionTarget('lock')
    value = sensor.getAspect('lock').getDatum('state')
    if !value?
      null
    else if @get('parameters').normallyLocked
      value
    else
      !value
