
const Marionette = require('backbone.marionette');
const util = require('../../util.coffee');
const PagesView = require('../../PagesView.js');

module.exports = class WeatherCapabilityView extends Marionette.View {
  template = Templates['capabilities/weather/weather'];

  className() { return 'weather-capability'; }

  regions() {
    return {
      pages: '.pages-container'
    }
  }
  
  modelEvents() {
    return {"change:state": 'render'};
  }

  initialize() {
    const intv = this.model.get('cameraRefreshInterval');
    if(intv != null) {
      this.cameraInterval = setInterval(this.render.bind(this), 1000 * intv);
    }
  }
  
  onRender() {
    console.log("showing pagesview");
    this.showChildView('pages', new PagesView({model: this.model}));
  }

  serializeData() {
    const conditions = this.model.get('state').conditions;
    return {
      temperature:   this.model.formatTemp(conditions.temperature),
      conditionName: util.weatherConditionToName(conditions.condition),
      conditionIcon: util.weatherConditionToIcon(conditions.condition,
                                                 conditions.isDay),
      camera:        this.model.cameraUrl()
    };
  }

  onDestroy() {
    if(this.cameraInterval != null) clearInterval(this.cameraInterval);
  }
}
