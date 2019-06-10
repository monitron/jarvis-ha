const _ = require('underscore');

const ControlBodyView = require('./ControlBodyView.js');
const SliderView = require('../SliderView.js');
const ColorWellView = require('../ColorWellView.js');

module.exports = class ColorLightControlBodyView extends ControlBodyView {
  template = Templates['controls/color-light'];

  className() { return super.className() + ' color-light-control'; }

  regions() {
    return {
      slider: '.slider-container',
      colorWell: '.color-well-container'
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

    const colorWellView = new ColorWellView({value: this.chromaValue()});
    this.listenTo(colorWellView, 'value:change',
                  (val) => this.onColorWellInput(val));
    this.showChildView('colorWell', colorWellView);
  }

  onStateChange() {
    this.getChildView('slider').setValue(this.sliderValue());
    this.getChildView('colorWell').setValue(this.chromaValue());
  }

  onSliderInput(newValue) {
    if(newValue == 'off')
      this.model.sendCommand('turnOff');
    else
      this.model.sendCommand('setBrightness', {value: newValue});
  }

  onColorWellInput(newValue) {
    this.model.sendCommand('setChroma', newValue);
  }

  chromaValue() {
    const state = this.model.get('state');
    console.log(state);
    if(!_.isEmpty(state.chroma))
      return state.chroma;
    else
      return null;
  }

  sliderValue() {
    const state = this.model.get('state');
    if(state.power && state.brightness > 0) {
      return state.brightness;
    } else {
      return 'off';
    }
  }
}
