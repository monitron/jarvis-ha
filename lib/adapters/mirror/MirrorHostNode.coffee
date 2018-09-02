request = require('request')
[AdapterNode] = require('../../AdapterNode')
MirrorAdapterNode = require('./MirrorAdapterNode')

module.exports = class MirrorHostNode extends AdapterNode
  defaults:
    pollInterval: 10 # seconds between polls

  initialize: ->
    super
    @setValid false
    @children.add new MirrorAdapterNode({id: 'contents'}, {adapter: this})
    setInterval (=> @poll()), @get('pollInterval') * 1000
    @poll();

  poll: ->
    options = url: @get('baseUrl') + 'api/adapters'
    request options, (err, res, body) =>
      if err
        @log 'error', "Failed polling #{options.url}: #{err}"
        @setValid false
      else
        @children.get('contents').processData children: JSON.parse(body)
        @setValid true
