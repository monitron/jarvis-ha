
const ControlBodyView = require('./ControlBodyView.js');
const SliderView = require('../SliderView.js');

module.exports = class ColorLightControlBodyView extends ControlBodyView {
  template = Templates['controls/color-light'];

  className() { return super.className() + ' color-light-control'; }

  regions() {
    return {
      slider: '.slider'
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
    if(state.power && state.brightness > 0) {
      return state.brightness;
    } else {
      return 'off';
    }
  }
}
