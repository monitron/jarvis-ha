const Marionette = require('backbone.marionette');

const util = require('../../util.coffee');
const SliderView = require('../../SliderView.js');

module.exports = class ChromaHueSaturationView extends Marionette.View {
  template = Templates['picker/chroma/hue-saturation'];

  className() {
    return 'chroma-picker';
  }
  
  regions() {
    return {
      hueSlider: '.hue-container',
      saturationSlider: '.saturation-container'
    };
  }
  
  onRender() {
    const hueSliderView = new SliderView({
      min: 0,
      max: 360,
      detents: [],
      qualitative: true,
      gradient: "#ff0000 0%, #ff0000 6%, #ffff00 21%, #00ff00 35%, #00ffff 50%, #0000ff 65%, #ff00ff 79%, #ff0000 94%, #ff0000 100%",
      value: this.model.get('hue'),
    });
    this.listenTo(hueSliderView, 'value:change',
                  (val) => this.onHueSliderInput(val));
    this.showChildView('hueSlider', hueSliderView);

    this.saturationSliderView = new SliderView({
      qualitative: true,
      gradient: this.saturationGradient(),
      detents: [],
      value: this.model.get('saturation')
    });
    this.listenTo(this.saturationSliderView, 'value:change',
                  (val) => this.onSaturationSliderInput(val));
    this.showChildView('saturationSlider', this.saturationSliderView);
  }
  
  onHueSliderInput(newValue) {
    this.model.set('hue', newValue);
    this.saturationSliderView.setGradient(this.saturationGradient());
    this.model.setValue('hue-saturation');
  }

  onSaturationSliderInput(newValue) {
    this.model.set('saturation', newValue);
    this.model.setValue('hue-saturation');
  }

  saturationGradient() {
    const rgb = util.hueSatToRgb(this.model.get('hue'), 100).join(',');
    return `white, rgb(${rgb})`;
  }
}
