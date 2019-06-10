
const util = require('./util.coffee');
const Marionette = require('backbone.marionette');

module.exports = class ColorWellView extends Marionette.View {
  template = () => "";

  className() {
    return 'color-well';
  }

  events() {
    return {
      click: 'onClick'
    };
  }

  initialize() {
    this.value = this.getOption('value');
  }

  onRender() {
    this.indicateValue();
  }

  indicateValue() {
    this.$el.toggleClass('undefined', this.value == null);
    this.$el.css('background', this.value == null ? '' :
                 util.chromaToRgbStyle(this.value));
  }

  setValue(newValue) {
    this.value = newValue;
    this.indicateValue();
  }

  onClick() {
    window.app.pickChroma(
      (newVal) => this.trigger('value:change', newVal), this.value);
  }
}
