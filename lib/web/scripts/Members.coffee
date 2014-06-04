
Backbone = require('backbone')
Member = require('./Member.coffee')

module.exports = class Members extends Backbone.Collection
  model: Member