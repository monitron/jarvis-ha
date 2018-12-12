moment = require('moment')
teslajs = require('teslajs')
[AdapterNode] = require('../../AdapterNode')
units = require('../../units')

module.exports = class TeslaVehicleNode extends AdapterNode
  aspects:
    batteryLevelSensor: {}
    chargingStatusSensor: {}
    vehicleRangeSensor: {}
    chargingTimeRemainingSensor: {}
    vehicleStatusSensor: {}
    locationSensor: {}

  chargingStatusMap:
    'Disconnected': 'disconnected'
    'Stopped':      'connected'
    'Charging':     'charging'
    'Complete':     'done'

  initialize: ->
    super
    setInterval((=> @poll()), @get('pollInterval') * 1000)
    @poll()

  poll: ->
    @log 'verbose', 'Polling vehicle data'
    if @_wakePollAttemptsLeft?
      @_wakePollAttemptsLeft -= 1
      if @_wakePollAttemptsLeft == 0 then @endWakePolling()
    teslajs.vehicleData @options(), (err, data) =>
      if err == "Error response: 408" # Vehicle is asleep
        @log 'verbose', 'Vehicle is asleep'
        @maybeWake()
      else if err?
        @log 'warn', "Poll failed for unexpected reason: #{err}"
      else
        @log 'verbose', 'Poll successful'
        @endWakePolling()
        asOf = moment(data.charge_state.timestamp).toDate()
        @_wakeTimer = asOf

        # Battery Level
        @getAspect('batteryLevelSensor').setData
          value: data.charge_state.battery_level / 100.0
          asOf:  asOf

        # Charging Status
        status = @chargingStatusMap[data.charge_state.charging_state]
        if status?
          @getAspect('chargingStatusSensor').setData value: status, asOf: asOf
        else
          @log 'warn', "Unknown charging_state: " +
            JSON.stringify(data.charge_state.charging_state)

        # Charging Time Remaining
        value = if data.charge_state.time_to_full_charge > 0
          data.charge_state.time_to_full_charge * 3600
        else
          null
        @getAspect('chargingTimeRemainingSensor').setData(
          {value: value, asOf:  asOf})

        # Range
        @getAspect('vehicleRangeSensor').setData
          value: units.milesToKm(data.charge_state.battery_range)
          asOf:  asOf

        # Vehicle Status
        @getAspect('vehicleStatusSensor').setData
          value: @shiftStatusToVehicleStatus(data.drive_state.shift_state)
          asOf:  asOf

        # Location
        if data.drive_state.latitude?
          @getAspect('locationSensor').setData
            value:
              lat: data.drive_state.latitude
              lng: data.drive_state.longitude
            asOf: moment(data.drive_state.gps_as_of, 'X').toDate()


  maybeWake: ->
    # Wake if we haven't received data or tried to wake in a long time
    if !@_wakeTimer? || moment().diff(@_wakeTimer, 'seconds') > @get('wakeInterval')
      @log 'verbose', 'Trying to wake vehicle'
      @_wakeTimer = moment()
      teslajs.wakeUp @options(), (err) =>
        if err?
          @log 'warn', "Wake request unsuccessful: #{err}"
        else
          @log 'verbose', 'Wake request in progress, starting wake polling'
          @_wakePollAttemptsLeft = @get('postWakePollAttempts')
          @_wakePollInterval =
            setInterval((=> @poll()), @get('postWakePollInterval') * 1000)

  endWakePolling: ->
    if @_wakePollInterval?
      @log 'verbose', 'Ending wake polling'
      clearInterval(@_wakePollInterval)
      delete @_wakePollAttemptsLeft
      delete @_wakePollInterval

  shiftStatusToVehicleStatus: (shiftStatus) ->
    if shiftStatus == null then return 'off'
    status = {
      P: 'parked'
      D: 'driving'
      R: 'driving'
    }[status]
    if !status? then @log 'warn', "Unknown shift_status: " +
      JSON.stringify(shiftStatus)
    status

  options: ->
    authToken: @get('authToken')
    vehicleID: @id
