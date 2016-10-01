
const Marionette = require('backbone.marionette');
const SliderView = require('./SliderView.js');

module.exports = class DimmerControlBodyView extends Marionette.View {
  template = Templates['controls/fan-speed'];

  className() { return 'control fan-speed-control'; }

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
    // We should be using the reported available speeds, but we are not.
    const sliderView = new SliderView({
      detents: [
        {position: 0,   label: 'Off',  key: 'off'},
        {position: 40,  label: 'Low',  key: 'low'},
        {position: 70,  label: 'Med',  key: 'med'},
        {position: 100, label: 'High', key: 'high'}],
      discrete: true,
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
    this.model.sendCommand('set', {value: newValue});
  }

  sliderValue() {
    return this.model.get('state').speed;
  }
}
