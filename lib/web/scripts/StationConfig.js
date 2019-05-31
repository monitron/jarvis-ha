const Backbone = require("backbone");

module.exports = class StationConfig extends Backbone.Model {
  urlRoot = 'api/stations';

  defaults() {
    return {
      'darkStartHour': 21,
      'darkEndHour': 6,
      'uiScale': 1.0,
      // displayType - defaults to auto
      // hasIdle - defaults to auto
    }
  };
};
