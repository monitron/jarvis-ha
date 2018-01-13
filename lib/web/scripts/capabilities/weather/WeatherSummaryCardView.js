
const Marionette = require('backbone.marionette');
const util = require('../../util.coffee');

module.exports = class WeatherSummaryCardView extends Marionette.View {
  template = Templates['capabilities/weather/summary-card'];

  ui() {
    return {
      alert: '.alert'
    };
  }

  events() {
    return {
      'click @ui.alert': 'onAlertClick',
      'click': 'onClick'
    };
  }
  
  initialize() {
    this.listenTo(this.model.capability(), 'change',
                  () => {if(this.model.collection != null) this.render()});
  }

  serializeData() {
    const cap = this.model.capability();
    const conditions = cap.get('state').conditions;
    const forecast = cap.dailyForecast();
    return {
      temperature:   cap.formatTemp(conditions.temperature),
      conditionName: util.weatherConditionToName(conditions.condition),
      conditionIcon: util.weatherConditionToIcon(conditions.condition,
                                                 conditions.isDay),
      alerts:        cap.alerts(),
      precipitation: cap.precipitation(),
      today:         forecast && forecast[0]
    }
  }

  onAlertClick(ev) {
    ev.stopPropagation();
    const id = $(ev.target).closest('.alert').data('id');
    this.model.capability().showAlert(id);
  }

  onClick() {
    this.model.capability().visit();
  }
}
