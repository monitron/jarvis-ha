
const Marionette = require('backbone.marionette');
const SliderView = require('./SliderView.js');

module.exports = class DimmerControlBodyView extends Marionette.View {
  template = Templates['controls/dimmer'];

  className() { return 'control dimmer-control'; }

  regions() {
    return {
      slider: '.slider'
    };
  }

  modelEvents() {
    return {
      'change:state': 'onStateChange'
    };
  }

  onRender() {
    const sliderView = new SliderView({
      detents: [
        {position: 0,   label: 'Off', key: 'off'},
        {position: 100, label: 'On'}],
      value: this.sliderValue()
    });
    this.listenTo(sliderView, 'value:change',
                  (val) => this.onSliderInput(val));
    this.showChildView('slider', sliderView);
  }

  onStateChange() {
    this.getChildView('slider').setValue(this.sliderValue());
  }

  onSliderInput(newValue) {
    if(newValue == 'off')
      this.model.sendCommand('turnOff');
    else
      this.model.sendCommand('setBrightness', {value: newValue});
  }

  sliderValue() {
    const state = this.model.get('state');
    if(state.power) {
      return state.brightness;
    } else {
      return 'off';
    }
  }
}
