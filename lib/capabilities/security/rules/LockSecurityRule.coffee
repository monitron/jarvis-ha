[SecurityRule] = require('../SecurityRule')

module.exports = class LockSecurityRule extends SecurityRule
  defaultParameters:
    name:           'A lock'
    presentTitle:   '<%= name %> is unlocked'
    pastTitle:      '<%= name %> was unlocked'
    normallyLocked: false

  initialize: ->
    super
    @listenTo this, 'mode:change connection:change', @evaluate

  state: ->
    sensor = @getConnectionTarget('lock')
    value = sensor.getAspect('lock').getDatum('state')
    if !value?
      undefined
    else if @get('parameters').normallyLocked
      value
    else
      !value
