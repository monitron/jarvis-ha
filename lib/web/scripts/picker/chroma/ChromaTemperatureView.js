const Marionette = require('backbone.marionette');

const SliderView = require('../../SliderView.js');

module.exports = class ChromaTemperatureView extends Marionette.View {
  template = Templates['picker/chroma/temperature'];

  className() {
    return 'chroma-picker';
  }

  regions() {
    return {
      slider: '.slider-container'
    };
  }

  onRender() {
    const sliderView = new SliderView({
      min: 153,
      max: 347,
      detents: [],
      qualitative: true,
      gradient: "rgb(255, 255, 251), rgb(255, 173, 101)",
      value: this.model.get('temperature'),
    });
    this.listenTo(sliderView, 'value:change',
                  (val) => this.onSliderInput(val));
    this.showChildView('slider', sliderView);
  }

  onSliderInput(newValue) {
    this.model.set('temperature', newValue);
    this.model.setValue('temperature');
  }
}
