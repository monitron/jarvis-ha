
const _ = require('underscore');
const Marionette = require('backbone.marionette');

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
      forecast: this.model.rawCondition('minutelyForecastNarrative'),
      alerts: this.model.alerts(),
      precipitation: this.model.precipitation(),
      conditions: this.model.detailedCurrentConditions()
    };
  }

  onAlertClick(ev) {
    this.model.showAlert($(ev.target).data('id'));
  }
}
