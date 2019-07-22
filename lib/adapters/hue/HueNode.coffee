lightState = require('node-hue-api').lightState

[AdapterNode] = require('../../AdapterNode')

HUE_SCALE = 182.0417    # range 0-65535 -> 0-360
SATURATION_SCALE = 2.55 # range 0-255 -> 0-100
BRIGHTNESS_SCALE = 2.55 # range 0-255 -> 0-100

# Abstract class for Hue light and group nodes
module.exports = class HueNode extends AdapterNode

  # Derived classes must have a setState method
  aspects:
    powerOnOff:
      commands:
        set: (node, value) ->
          node.setState(on: value).then ->
            node.getAspect('powerOnOff').setData state: value
    brightness:
      commands:
        set: (node, value) ->
          node.setState(lightState.create().turnOn().brightness(value)).then ->
            node.getAspect('brightness').setData state: value
            node.getAspect('powerOnOff').setData state: true
    chroma:
      commands:
        set: (node, value) ->
          state = lightState.create().turnOn()
          switch value.type
            when 'temperature' then state.ct(value.temperature)
            when 'hue-saturation'
              state.hue(value.hue * HUE_SCALE)
                .sat(value.saturation * SATURATION_SCALE)
            else node.log 'error', "Unknown chroma type #{value.type}"
          node.setState(state).then ->
            node.getAspect('chroma').setData value
            node.getAspect('powerOnOff').setData state: true

  _processData: (data) ->
    if data.on?
      @getAspect('powerOnOff').setData state: data.on
    else
      @getAspect('powerOnOff').clearData()

    if data.bri?
      @getAspect('brightness').setData state: data.bri / BRIGHTNESS_SCALE
    else
      @getAspect('brightness').clearData()

    chroma = @getAspect('chroma')
    if data.colormode?
      switch data.colormode
        when 'ct'
          if data.ct?
            chroma.setData
              type: 'temperature'
              temperature: data.ct # mired
          else
            chroma.clearData()
        when 'xy', 'hs'
          if data.hue? and data.sat?
            chroma.setData
              type: 'hue-saturation'
              hue: data.hue / HUE_SCALE
              saturation: data.sat / SATURATION_SCALE
          else
            chroma.clearData()
        else @log 'warn', "Unknown colormode #{data.colormode}"
    else
      chroma.clearData()