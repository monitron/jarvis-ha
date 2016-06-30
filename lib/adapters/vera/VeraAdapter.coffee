
_ = require('underscore')
request = require('request')
Q = require('q')
Adapter = require('../../Adapter')
VeraLockNode = require('./VeraLockNode')

module.exports = class VeraAdapter extends Adapter
  name: "Vera Home Controller"

  defaults:
    pollInterval:    15 # Seconds between status checks
    jobPollInterval: 2  # Seconds between status checks while a job is active

  initialize: ->
    super
    @_activeJobs = []
    @setValid false

  start: ->
    @discoverDevices()

  discoverDevices: ->
    @log 'debug', 'Discovering devices...'
    @_request('user_data').then (result) =>
      @_shiz = result.devices
      for device in result.devices
        switch device.device_type
          when 'urn:schemas-micasaverde-com:device:DoorLock:1'
            @log 'debug', "Enumerating device ID #{device.id} " +
              "(#{device.name}) as a door lock"
            node = new VeraLockNode({id: device.id}, {adapter: this})
            @children.add node
            node.processData device.states
          else
            @log 'verbose', "Ignoring device #{device.id} with unknown type " +
              "#{device.device_type}"
      @_startPolling()
      @setValid true

  requestAction: (device, service, action, options = {}) ->
    deferred = Q.defer()
    query =
      DeviceNum: device
      serviceId: service
      action:    action
    @_request('action', Object.assign(query, options))
      .fail (err) => deferred.reject(err)
      .then (res) =>
        @_activeJobs.push
          id: res['u:SetTargetResponse']['JobID']
          failure: =>
            @log 'warn', "Action failed (#{device} #{action})"
            deferred.reject()
          success: =>
            @log 'debug', "Action succeeded (#{device} #{action})"
            deferred.resolve()
        @_startPolling()
    deferred.promise

  # Start or restart polling, on an interval taking into account whether there
  # are active jobs to be checked on
  _startPolling: ->
    interval = @get(if _.isEmpty(@_activeJobs) then 'pollInterval' else
      'jobPollInterval')
    @log 'debug', "Will poll every #{interval} seconds!"
    if @_interval then clearInterval(@_interval)
    @_interval = setInterval((=> @_requestStatus()), interval * 1000)

  _requestStatus: ->
    @log 'verbose', 'Requesting status'
    @_request('status')
      .fail (err) =>
        @log 'warn', "Failed requesting status (#{err})"
      .then (res) =>
        hadActiveJobs = !_.isEmpty(@_activeJobs)
        for device in res.devices
          child = @children.get(device.id)
          if child?
            @log 'verbose', "Processing status for device #{child.id}"
            child.processData device.states
            for job in device.Jobs
              activeJob = _.findWhere(@_activeJobs, id: job.id)
              if activeJob?
                @log 'verbose', "Device #{device.id} active job #{job.id} " +
                  "status is #{job.status}"
                switch job.status
                  when '2', '3' # Failed or aborted
                    activeJob.failure()
                    @_activeJobs = _.without(@_activeJobs, activeJob)
                  when '4' # Succeeded
                    activeJob.success()
                    @_activeJobs = _.without(@_activeJobs, activeJob)
            if hadActiveJobs and _.isEmpty(@_activeJobs) then @_startPolling()

  _request: (reqType, options = {}) ->
    deferred = Q.defer()
    requestOptions =
      url: "http://#{@get('host')}:3480/data_request"
      qs:  Object.assign(options, {id: reqType, 'output_format': 'json'})
    request requestOptions, (err, res, body) =>
      if err?
        @log 'warn', "Request (#{reqType} failed: #{err}"
        deferred.reject err
      else
        deferred.resolve JSON.parse(body)
    deferred.promise
