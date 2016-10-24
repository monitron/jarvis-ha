
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
      cloudy:       'Clouds'
      mostlyCloudy: 'Overcast'
      partlyCloudy: 'Many Clouds'
      partlySunny:  'Some Clouds'
      mostlySunny:  'Few Clouds'
      sunny:        'Sun'
    map[cond] or 'Unknown'