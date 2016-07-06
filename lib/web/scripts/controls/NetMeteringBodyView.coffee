
Backbone = require('backbone')
_ = require('underscore')

module.exports = class NetMeteringBodyView extends Backbone.View
  render: ->
    state = @model.get('state')
    used = state.used or 0
    generated = state.generated or 0
    max = _.max([used, generated])
    context =
      usedText:      used.toFixed(1)
      generatedText: generated.toFixed(1)
      usedBar:       (used / max) * 100
      generatedBar:  (generated / max) * 100
      pctGenerated:  ((generated / used) * 100).toFixed(0)
    @$el.html Templates['controls/netMetering'](context)
    this
