moment = require('moment')
teslajs = require('teslajs')
[AdapterNode] = require('../../AdapterNode')
units = require('../../units')

module.exports = class TeslaVehicleNode extends AdapterNode
  aspects:
    batteryLevelSensor: {}
    chargingStatusSensor: {}
    vehicleRangeSensor: {}

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
        aspect = @getAspect('batteryLevelSensor')
        aspect.setData
          value: data.charge_state.battery_level / 100.0
          asOf:  asOf

        # Charging Status
        status = @chargingStatusMap[data.charge_state.charging_state]
        if status?
          aspect = @getAspect('chargingStatusSensor')
          aspect.setData value: status, asOf: asOf
        else
          @log 'warn', "Unknown charging_state: " +
            JSON.stringify(data.charge_state.charging_state)

        # Range
        aspect = @getAspect('vehicleRangeSensor')
        aspect.setData
          value: units.milesToKm(data.charge_state.battery_range)
          asOf:  asOf

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

  options: ->
    authToken: @get('authToken')
    vehicleID: @id
