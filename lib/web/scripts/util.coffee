
module.exports =
  tempToFahrenheit: (c) -> (c * (9.0/5)) + 32

  weatherConditionToIcon: (cond, day) ->
    map = #         [neutral, day, night]
      clear:        ['wi-day-sunny', 'wi-day-sunny', 'wi-night-clear']
      lightSnow:    ['wi-snow', 'wi-day-snow', 'wi-night-alt-snow']
      rain:         ['wi-rain', 'wi-day-rain', 'wi-night-alt-rain']
      sleet:        ['wi-sleet', 'wi-day-sleet', 'wi-night-alt-sleet']
      snow:         ['wi-snow', 'wi-day-snow', 'wi-night-alt-snow']
      thunderstorm: ['wi-thunderstorm', 'wi-day-thunderstorm', 'wi-night-alt-thunderstorm']
      fog:          ['wi-fog', 'wi-day-fog', 'wi-night-fog']
      hazy:         ['wi-day-haze', 'wi-day-haze', 'wi-day-haze']
      cloudy:       ['wi-cloudy', 'wi-cloudy', 'wi-cloudy']
      mostlyCloudy: ['wi-cloud', 'wi-day-cloudy', 'wi-night-alt-cloudy']
      partlyCloudy: ['wi-cloud', 'wi-day-cloudy', 'wi-night-alt-cloudy']
      partlySunny:  ['wi-cloud', 'wi-day-cloudy', 'wi-night-alt-cloudy']
      mostlySunny:  ['wi-day-sunny', 'wi-day-sunny', 'wi-night-clear']
      wind:         ['wi-strong-wind', 'wi-strong-wind', 'wi-strong-wind']
    condSet = map[cond]
    if condSet?
      if day?
        if day then condSet[1] else condSet[2]
      else
        condSet[0]
    else
      'wi-na'

  weatherConditionToName: (cond) ->
    map =
      clear:        'Clear'
      lightSnow:    'Light Snow'
      rain:         'Rain'
      sleet:        'Sleet'
      snow:         'Snow'
      thunderstorm: 'Thunderstorm'
      fog:          'Fog'
      haze:         'Haze'
      cloudy:       'Cloudy'
      mostlyCloudy: 'Overcast'
      partlyCloudy: 'Partly Cloudy'
      partlySunny:  'Partly Sunny'
      mostlySunny:  'Mostly Sunny'
      sunny:        'Sunny'
      wind:         'Windy'
    map[cond] or 'Unknown'

  angleToCardinalDirection: (degrees) ->
    if degrees < 11.25 or degrees >= 348.75 then return 'N'
    if degrees < 33.75  then return 'NNE'
    if degrees < 56.25  then return 'NE'
    if degrees < 78.75  then return 'ENE'
    if degrees < 101.25 then return 'E'
    if degrees < 123.75 then return 'ESE'
    if degrees < 146.25 then return 'SE'
    if degrees < 168.75 then return 'SSE'
    if degrees < 191.25 then return 'S'
    if degrees < 213.75 then return 'SSW'
    if degrees < 236.25 then return 'SW'
    if degrees < 258.75 then return 'WSW'
    if degrees < 281.25 then return 'W'
    if degrees < 303.75 then return 'WNW'
    if degrees < 326.25 then return 'NW'
    return 'NNW'

  describeUvIndex: (index) ->
    if index < 3  then return "Low"
    if index < 6  then return "Moderate"
    if index < 8  then return "High"
    if index < 11 then return "Very High"
    return "Extreme"

  describeDewpoint: (dewpoint) ->
    if dewpoint < 12.78 then return "Pleasant"
    if dewpoint < 16.11 then return "Comfortable"
    if dewpoint < 18.89 then return "Sticky"
    if dewpoint < 21.67 then return "Uncomfortable"
    if dewpoint < 24.44 then return "Oppressive"
    return "Miserable"

  pressureToInHg: (pressure) ->
    pressure * 0.02953

  speedToMPH: (speed) ->
    speed * 0.621371

  lengthToInches: (length) -> # input: mm
    length * 0.0393701

  distanceToMiles: (dist) -> # input: km
    dist * 0.621371

  resourceURI: (adapterPath, resource) ->
    "api/resources/#{adapterPath.join('/')}/#{resource}?#{new Date().getTime()}"

  loadImageOntoCanvas: (canvas, uri, aspectRatio) ->
    context = canvas.getContext('2d')
    img = new Image();
    img.addEventListener 'load', ->
      imgAspect = aspectRatio || (img.width / img.height)
      canvasAspect = canvas.width / canvas.height
      drawWidth = canvas.width
      drawHeight = canvas.height
      if imgAspect >= canvasAspect
        drawHeight = canvas.width / imgAspect
      else
        drawWidth = canvas.height * imgAspect
      context.drawImage img,
        (canvas.width - drawWidth) / 2,
        (canvas.height - drawHeight) / 2,
        drawWidth,
        drawHeight
    img.src = uri