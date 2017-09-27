
const _ = require('underscore');
const Marionette = require('backbone.marionette');

module.exports = class GenericPickerView extends Marionette.View {
  template = Templates['picker/generic-picker'];

  className() {
    return 'generic-picker';
  }

  ui() {
    return {
      item: '.item'
    };
  }

  events() {
    return {
      'click @ui.item': 'onPick'
    };
  }

  serializeData() {
    return {
      items: this.getOption('choices').map((choice) =>
        _.defaults({selected: choice.id === this.getOption('current')}, choice))
    };
  }

  onPick(event) {
    const id = $(event.target).closest('.item').data('item');
    this.getOption('callback')(id);
    this.destroy();
  }
}
