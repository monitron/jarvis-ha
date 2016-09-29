
const Marionette = require('backbone.marionette');
const _ = require('underscore');

module.exports = class SliderView extends Marionette.View {
  template = Templates['controls/slider'];

  // options = {
  //   value: 0, // number or string corresponding to detent key
  //   detents: []
  // };
  // Detent options:
  //   key:      corresponds to current value
  //   position: number 0 to 100
  //   label:    string

  ui() {
    return {
      track:       '.track',
      handle:      '.handle',
      trail:       '.trail',
      handleLabel: '.handle .label'
    }
  }

  events() {
    return {
      'click @ui.handle': 'onHandleClick',
      'click @ui.track':  'onTrackClick'
    };
  }

  serializeData() {
    return {
      detents: this.getOption('detents')
    };
  }

  initialize() {
    this.value = this.getOption('value');
  }

  onRender() {
    this.indicateValue();
  }

  setValue(newValue) {
    this.value = newValue;
    this.indicateValue();
  }

  indicateValue() {
    var position, label;
    if(_.isString(this.value)) {
      const detent = _.findWhere(this.getOption('detents'), {key: this.value});
      ({position, label} = detent);
    } else {
      position = this.value;
      label = `${this.value}%`;
    }
    this.ui.handle.css('margin-left', `${position}%`);
    this.ui.trail.css('width', `${position}%`);
    this.ui.handleLabel.text(label);
  }

  onHandleClick(event) {
    // Clicking the handle does nothing. NOTHING!
    event.stopPropagation();
  }

  onTrackClick(event) {
    const position = this.offsetToPosition(event.offsetX);
    this.trigger('value:change', this.positionToValue(position));
  }

  positionToValue(position) {
    // Snap to detents
    for(const detent of this.getOption('detents')) {
      if(Math.abs(detent.position - position) <= 5) {
        return (detent.key != null) ? detent.key : detent.position;
      }
    }
    return position;
  }

  offsetToPosition(offset) {
    return (offset / this.ui.track.width()) * 100;
  }
}
