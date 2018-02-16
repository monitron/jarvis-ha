_ = require('underscore')

Adapter = require('../../Adapter')
MockNode = require('./MockNode')

# Configure me like so:
#
# adapters:
#   - id: mock
#     children:
#       a-door:
#         aspects:
#           openCloseSensor:
#             data:
#               state: false
#
# Then manipulate me like so:
#
# $ coffee
# coffee> jarvis = require('./lib/jarvis-ha'); server = new jarvis.Server()
# coffee> server.adapters.get('mock').children.get('a-door').
#   getAspect('openCloseSensor').setData(state: true)

module.exports = class MockAdapter extends Adapter
  name: 'Mock'
  defaults:
    children: {}

  start: ->
    for id, config of @get('children')
      config = _.defaults({id: id}, config)
      @children.add new MockNode(config, adapter: this)