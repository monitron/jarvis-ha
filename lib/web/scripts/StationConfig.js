const Backbone = require("backbone");

module.exports = class StationConfig extends Backbone.Model {
  urlRoot = '/api/stations';
};
