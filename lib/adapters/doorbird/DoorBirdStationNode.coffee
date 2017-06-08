Q = require('q')
request = require('request')

[AdapterNode] = require('../../AdapterNode')

module.exports = class DoorBirdStationNode extends AdapterNode
  aspects:
    stillCamera: {}

  resources:
    still: (node) ->
      deferred = Q.defer()
      options =
        url: node._apiBaseUrl() + "image.cgi"
        encoding: null # Expect binary data
        auth:
          username: node.get('username')
          password: node.get('password')
      request options, (err, res, body) ->
        if err
          node.log 'error', "Image request #{options.url} failed: #{err}"
          deferred.reject err
        else
          deferred.resolve
            contentType: res.headers['content-type']
            data: body
      deferred.promise

  initialize: ->
    super
    @getAspect('stillCamera').setData
      imageResource: 'still'

  _apiBaseUrl: ->
    "http://#{@get('host')}/bha-api/"