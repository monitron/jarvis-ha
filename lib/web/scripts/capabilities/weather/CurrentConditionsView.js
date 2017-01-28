
const _ = require('underscore');
const Marionette = require('backbone.marionette');
const WeatherAlertView = require('./WeatherAlertView.js');

module.exports = class CurrentConditionsView extends Marionette.View {
  template = Templates['capabilities/weather/current'];

  className() { return 'current-conditions'; }

  ui() {
    return {
      alert: '.alerts li'
    };
  }

  events() {
    return {
      'click @ui.alert': 'onAlertClick'
    };
  }

  serializeData() {
    return {
      alerts: this.model.alerts(),
      conditions: this.model.detailedCurrentConditions()
    };
  }

  onAlertClick(ev) {
    const id = $(ev.target).data('id');
    const alert = _.findWhere(this.model.alerts(), {id: id});
    const view = new WeatherAlertView({model: alert});
    window.app.view.showModalView('Weather Alert', view);
  }
}
