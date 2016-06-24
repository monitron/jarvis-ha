[Control] = require('../Control')

module.exports = class DoorControl extends Control
  _getState: ->
    sensor = @getConnectionTarget('openCloseSensor')
    open: sensor?.getAspect('openCloseSensor').getDatum('state')