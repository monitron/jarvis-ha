Q = require('q')
request = require('request')
stream = require('stream')

[AdapterNode] = require('../../AdapterNode')

module.exports = class DoorBirdStationNode extends AdapterNode
  aspects:
    stillCamera: {}
    occupancySensor: {}
    momentarySwitchSensor: {}

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
    @setValid false
    @getAspect('stillCamera').setData
      imageResource: 'still'
      aspectRatio: 16.0 / 9
    @connectEventStream()

  connectEventStream: ->
    options =
      url: @_apiBaseUrl() + "monitor.cgi?ring=doorbell,motionsensor"
      auth:
        username: @get('username')
        password: @get('password')
    @_request = request options, (err, res, body) =>
      if err
        @log 'error', "Monitor #{options.url} failed: #{err}, will retry"
        setTimeout (=> @connectEventStream()),
          @get('eventStreamReconnectInterval') * 1000
    estream = new stream.PassThrough()
    @_request.pipe estream
    estream.on 'data', (data) => @processStreamData(data)
    @resetStreamDataTimeout()

  processStreamData: (data) ->
    lines = data.toString().split("\r\n")
    hadValidData = false
    for line in lines
      [key, value] = line.split(":")
      switch key
        when "doorbell"
          @getAspect('momentarySwitchSensor').setData value: value == 'H'
          hadValidData = true
        when "motionsensor"
          @getAspect('occupancySensor').setData value: value == 'H'
          hadValidData = true
    if hadValidData
      @setValid true
      @resetStreamDataTimeout()

  resetStreamDataTimeout: ->
    clearTimeout @_timeout
    reconnect = =>
      @setValid false
      @_request.abort()
      @log 'warn', "Event stream timed out...will try to reconnect"
      @connectEventStream()
    @_timeout = setTimeout(reconnect, @get('eventStreamTimeout') * 1000)

  _apiBaseUrl: ->
    "http://#{@get('host')}/bha-api/"
