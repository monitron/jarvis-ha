
const ControlBodyView = require('./ControlBodyView.js');
const SliderView = require('./SliderView.js');

module.exports = class SwitchControlBodyView extends ControlBodyView {
  template = Templates['controls/switch'];

  className() { return super.className() + ' switch-control'; }

  regions() {
    return {
      slider: '.slider'
    };
  }

  onRender() {
    const sliderView = new SliderView({
      detents: [
        {position: 0,   label: 'Off',  key: 'off'},
        {position: 100,  label: 'On',  key: 'on'}],
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
    this.model.sendCommand(newValue == 'on' ? 'turnOn' : 'turnOff');
  }

  sliderValue() {
    return this.model.get('state').power ? 'on' : 'off';
  }
}
