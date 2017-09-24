
_ = require('underscore')
sqlite3 = require('sqlite3')
winston = require('winston')
Q = require('q')
[Event, Events] = require('./Event')

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

  createEvent: (event) ->
    @log 'verbose', "Creating event #{event.id} (#{event.get('title')})"
    deferred = Q.defer()
    sql = "INSERT INTO events (id, source_type, source_id, reference," +
      "importance, start, end, title, description) " +
      "VALUES ($id, $sourceType, $sourceId, $reference, " +
      "$importance, $start, $end, $title, $description)"
    @_db.run sql, @_sqlParamsForEvent(event), (err) =>
      if err?
        @log 'error', "Failed to persist event: #{err}"
        deferred.reject(err)
      else
        deferred.resolve()
    deferred.promise

  searchEvents: (query) ->
    # Query options, all strings:
    # minImportance: specifies a minimum importance
    # timesStart:    the earliest UNIX timestamp that will be included
    # timesEnd:      the latest UNIX timestamp that will be included
    # sourceType:    specifies a type of source e.g. capability
    # sourceId:      specifies a source ID
    @log 'verbose', "Searching events with query #{JSON.stringify(query)}"
    deferred = Q.defer()
    predicates = []
    params = {}
    if query.minImportance?
      importances = Events.prototype.importances
      qis = importances[0..importances.indexOf(query.minImportance)]
      qis = qis.map((i) -> "'#{i}'").join(', ')
      predicates.push "importance in (#{qis})"
    if query.timesStart?
      predicates.push '(start >= $timesStart OR end >= $timesStart)'
      params['$timesStart'] = Number(query.timesStart)
    if query.timesEnd?
      predicates.push 'start <= $timesEnd'
      params['$timesEnd'] = Number(query.timesEnd)
    if query.sourceType?
      predicates.push 'source_type = $sourceType'
      params['$sourceType'] = query.sourceType
    if query.sourceId?
      predicates.push 'source_id = $sourceId'
      params['$sourceId'] = query.sourceId
    sql = "SELECT * FROM events WHERE " + predicates.join(" AND ")
    @_db.all sql, params, (err, rows) =>
      if err?
        @log 'error', "Failed to search events: #{err}"
        deferred.reject(err)
      else
        deferred.resolve new Events(rows.map((row) => @_eventJSONFromSqlRow(row)))
    deferred.promise

  updateEvent: (event) ->
    @log 'verbose', "Updating event #{event.id} (#{event.get('title')})"
    deferred = Q.defer()
    sql = "UPDATE events SET end = $end, title = $title, " +
      "description = $description WHERE id = $id"
    params = _.pick(@_sqlParamsForEvent(event), '$end', '$title',
      '$description', '$id')
    @_db.run sql, params, (err) =>
      if err?
        @log 'error', "Failed to update persisted event: #{err}"
        deferred.reject(err)
      else
        deferred.resolve()
    deferred.promise

  _sqlParamsForEvent: (event) ->
    '$id':          event.id
    '$sourceType':  event.get('sourceType')
    '$sourceId':    event.get('sourceId')
    '$reference':   event.get('reference')
    '$importance':  event.get('importance')
    '$title':       event.get('title')
    '$description': event.get('description')
    '$start': if event.has('start') then Math.floor(event.get('start') / 1000)
    '$end':   if event.has('end')   then Math.floor(event.get('end') / 1000)

  _eventJSONFromSqlRow: (row) ->
    id:          row.id
    sourceType:  row['source_type']
    sourceId:    row['source_id']
    reference:   row.reference
    importance:  row.importance
    title:       row.title
    description: row.description
    start:       row.start? && new Date(row.start * 1000)
    end:         row.end?   && new Date(row.end * 1000)

  _createIfNeeded: ->
    @_db.serialize =>
      @_db.run "CREATE TABLE IF NOT EXISTS adapter_data (" +
        "adapter TEXT, key TEXT, value TEXT)"
      @_db.run "CREATE TABLE IF NOT EXISTS events (id TEXT, " +
        "source_type TEXT, source_id TEXT, reference TEXT, importance TEXT,
        start INTEGER, end INTEGER, title TEXT, description TEXT)"

  log: (level, message) ->
    winston.log level, "[Persistence] #{message}"