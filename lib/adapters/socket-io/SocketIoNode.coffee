_ = require('underscore')

[AdapterNode] = require('../../AdapterNode')

module.exports = class SocketIoNode extends AdapterNode
  defaults:
    aspects: {}

  aspects: ->
    _.mapObject @get('aspects'), (config, aspectKey) =>
      commands: _.mapObject (config.commands or {}), (cmdConfig, cmdKey) =>
        (node) -> node.doCommand(aspectKey, cmdKey)

  initialize: ->
    super
    # gather list of servers to listen to
    @_serverNames = _.chain(@get('aspects'))
      .map (aspectSpec) -> _.values(aspectSpec.data or {})
      .flatten()
      .map (datumSpec) -> datumSpec.server
      .uniq()
      .value()
    for server in @_serverNames
      client = @adapter.client(server)
      client.on 'connect', => @_setValidity()
      client.on 'disconnect', => @_setValidity()
      client.on 'change', ({slot, value}) => @_processDatum server, slot, value
    @_setValidity()

  doCommand: (aspectKey, cmdKey) ->
    deferred = Q.defer()
    command = @get('aspects')[aspectKey].commands[cmdKey]
    client = @adapter.client(command.server)
    client.emit 'command', command.slot, (result) =>
      if _.isString(result) # it's an error message
        deferred.reject(result)
      else
        deferred.resolve()
    deferred.promise

  _processDatum: (server, slot, value) ->
    for aspectKey, aspectSpec of @get('aspects')
      for datumKey, datumSpec of aspectSpec.data
        if datumSpec.server == server and datumSpec.slot == slot
          @getAspect(aspectKey).setDatum datumKey, value

  _setValidity: ->
    v = _.every(@_serverNames,
      (server) => @adapter.client(server).connected)
    @log 'warn', "validity: #{v}"
    @setValid v