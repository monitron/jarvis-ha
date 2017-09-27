
const ControlBodyView = require('./ControlBodyView.js');
const SliderView = require('../SliderView.js');

module.exports = class MediaControlBodyView extends ControlBodyView {
  template = Templates['controls/media'];

  className() { return super.className() + ' media-control'; }

  regions() {
    return {
      slider: '.slider'
    };
  }

  onRender() {
    const sliderView = new SliderView({
      detents: this.buildDetents(),
      discrete: true,
      qualitative: true,
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
    if(newValue == 'off') {
      this.model.sendCommand('turnOff');
    } else {
      this.model.sendCommand('setSource', {value: newValue});
    }
  }

  sliderValue() {
    const state = this.model.get('state');
    if(state.power == false) {
      return 'off';
    } else {
      return state.source;
    }
  }

  buildDetents() {
    const sources = this.model.get('state').sourceChoices;
    const symbols = this.model.get('parameters').sourceSymbols || {};
    let position = 100;
    const detents = Object.keys(sources).map(function(sourceKey) {
      const symbol = symbols[sourceKey] || {};
      const detent = {
        position: position,
        key: sourceKey
      };
      if(symbol.hasOwnProperty('icon')) {
        detent.icon = symbol.icon;
      } else if(symbol.hasOwnProperty('text')) {
        detent.label = symbol.text;
      } else {
        detent.label = sources[sourceKey].slice(0, 3);
      }
      position = position - 15;
      return detent;
    });
    return [{position: 0, label: 'Off', key: 'off'}, ...detents];
  }
}
