const _ = require('underscore');
const Backbone = require('backbone');

const ChromaTemperatureView = require('./ChromaTemperatureView.js');
const ChromaHueSaturationView = require('./ChromaHueSaturationView.js');

module.exports = class ChromaPicker extends Backbone.Model {
  defaults() {
    return {
      hue: 0,
      saturation: 100,
      temperature: 200,
      page: 'hue-saturation'
    };
  }
  
  initialize(attrs, options) {
    this.callback = options.callback;
    const value = this.get('value');
    if(value != null) {
      this.set('page', value.type);
      switch(value.type) {
      case 'hue-saturation':
        this.set('saturation', value.saturation);
        this.set('hue', value.hue);
        break;

      case 'temperature':
        this.set('temperature', value.temperature);
        break;
      }
    }
  }

  pages() {
    const pages = [
      {
        id: 'temperature',
        name: 'White',
        view: () => new ChromaTemperatureView({model: this})
      },
      {
        id: 'hue-saturation',
        name: 'Color',
        view: () => new ChromaHueSaturationView({model: this})
      }
    ];
    _.findWhere(pages, {id: this.get('page')}).active = true;
    return pages;
  }

  setValue(type) {
    switch(type) {
      case 'temperature':
      this.set('value', {
        type: type,
        temperature: this.get('temperature')
      });
      break;

      case 'hue-saturation':
      this.set('value', {
        type: type,
        hue: this.get('hue'),
        saturation: this.get('saturation')
      });
      break;
    }
    this.callback(this.get('value'));
  }
}
