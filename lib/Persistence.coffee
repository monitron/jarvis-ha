
sqlite3 = require('sqlite3')
winston = require('winston')
Q = require('q')

module.exports = class Persistence
  constructor: ->
    @log 'verbose', "Opening persistence database"
    @_db = new sqlite3.Database('jarvis.sqlite3')
    @_createIfNeeded()

  getAdapterData: (adapter, key) ->
    deferred = Q.defer()
    sql = "SELECT value FROM adapter_data WHERE adapter = $a AND key = $k"
    @_db.get sql, {'$a': adapter, '$k': key}, (err, row) =>
      if err?
        deferred.reject err
      else
        data = if row?.value? then JSON.parse(row.value) else undefined
        deferred.resolve data
    deferred.promise

  setAdapterData: (adapter, key, value) ->
    if !value? then return @unsetAdapterData(adapter, key)
    deferred = Q.defer()
    @getAdapterData(adapter, key)
      .then (oldValue) =>
        sql = if oldValue?
          "UPDATE adapter_data SET value = $v WHERE adapter = $a AND key = $k"
        else
          "INSERT INTO adapter_data (adapter, key, value) VALUES ($a, $k, $v)"
        params = {'$a': adapter, '$k': key, '$v': JSON.stringify(value)}
        @_db.run sql, params, (err) =>
          if err? then deferred.reject(err) else deferred.resolve()
      .fail (err) => deferred.reject(err)
    deferred.promise

  unsetAdapterData: (adapter, key) ->
    deferred = Q.defer()
    sql = "DELETE FROM adapter_data WHERE adapter = $a AND key = $k"
    @_db.run sql, {'$a': adapter, '$k': key}, (err) =>
      if err? then deferred.reject(err) else deferred.resolve()
    deferred.promise

  _createIfNeeded: ->
    @_db.serialize =>
      @_db.run "CREATE TABLE IF NOT EXISTS adapter_data (" +
        "adapter TEXT, key TEXT, value TEXT)"

  log: (level, message) ->
    winston.log level, "[Persistence] #{message}"