
const Marionette = require('backbone.marionette');
const util = require('../../util.coffee');
const DailyForecastView = require('./DailyForecastView.js');
const CurrentConditionsView = require('./CurrentConditionsView.js');

module.exports = class WeatherCapabilityView extends Marionette.View {
  template = Templates['capabilities/weather/weather'];

  className() { return 'weather-capability'; }

  pageViewClasses = {
    daily: DailyForecastView,
    hourly: DailyForecastView,
    current: CurrentConditionsView
  }
  
  ui() {
    return {
      pageSelect: '.select li'
    };
  }

  regions() {
    return {
      page: '.page'
    };
  }

  events() {
    return {
      'click @ui.pageSelect': 'onPageSelectClick'
    };
  }

  modelEvents() {
    return {change: 'render'};
  }

  initialize() {
    const intv = this.model.get('cameraRefreshInterval');
    if(intv != null) {
      this.cameraInterval = setInterval(this.render.bind(this), 1000 * intv);
    }
  }
  
  onRender() {
    const pageViewClass = this.pageViewClasses[this.model.get('currentPage')];
    this.showChildView('page', new pageViewClass({model: this.model}));
  }

  serializeData() {
    const conditions = this.model.get('state').conditions;
    return {
      pages:         this.model.pages(),
      temperature:   this.model.formatTemp(conditions.temperature),
      conditionName: util.weatherConditionToName(conditions.condition),
      conditionIcon: util.weatherConditionToIcon(conditions.condition,
                                                 conditions.isDay),
      camera:        this.model.cameraUrl()
    };
  }

  onPageSelectClick(ev) {
    const id = $(ev.target).data('id');
    this.model.set('currentPage', id);
  }

  onDestroy() {
    if(this.cameraInterval != null) clearInterval(this.cameraInterval);
  }
}
