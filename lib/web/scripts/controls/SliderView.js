
const Marionette = require('backbone.marionette');
const _ = require('underscore');
const Dragdealer = require('dragdealer').Dragdealer;

module.exports = class SliderView extends Marionette.View {
  template = Templates['controls/slider'];

  // options = {
  //   value: 0, // number or string corresponding to detent key
  //   detents: [],
  //   discrete: false
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

  serializeData() {
    return {
      detents: this.getOption('detents')
    };
  }

  initialize() {
    this.value = this.getOption('value');
    this.dragEventEnabled = true;
  }

  onRender() {
    _.defer(() => {
      this.drag = new Dragdealer(this.ui.track[0], {
        slide: false,
        speed: 1,
        animationCallback: (x) => this.indicateValue(this.positionToValue(x * 100), true),
        callback: (x) => {
          const newVal = this.positionToValue(x * 100);
          if(this.dragEventEnabled) {
            if(newVal != this.value) {
              this.trigger('value:change', newVal);
            }
            _.defer(this.indicateValue.bind(this, newVal));
          }
        }
      });
      this.indicateValue();
    });
  }

  setValue(newValue) {
    this.value = newValue;
    this.indicateValue();
  }

  indicateValue(tempValue = null, dragging = false) {
    var position, label;
    const isTemp = tempValue != null;
    const value = isTemp ? tempValue : this.value;
    if(_.isString(value)) {
      const detent = _.findWhere(this.getOption('detents'), {key: value});
      ({position, label} = detent);
    } else {
      position = value;
      label = `${Math.round(value)}%`;
    }
    if(!dragging) {
      this.dragEventEnabled = false;
      this.drag.setValue(position / 100.0, 0, true);
      this.dragEventEnabled = true;
      this.ui.trail.css('width', `${position}%`);
    }
    this.ui.handleLabel.text(label);
  }

  positionToValue(position) {
    if(this.getOption('discrete')) {
      // Snap to closest detent, regardless of distance
      let closest = Infinity, closestPosition;
      for(const detent of this.getOption('detents')) {
        const distance = Math.abs(detent.position - position);
        if(distance < closest) {
          closest = distance;
          closestPosition = detent.key;
        }
      }
      return closestPosition;
    } else {
      // Snap to detents if close
      for(const detent of this.getOption('detents')) {
        if(Math.abs(detent.position - position) <= 5) {
          return (detent.key != null) ? detent.key : detent.position;
        }
      }
      return position;
    }
  }

  offsetToPosition(offset) {
    return (offset / this.ui.track.width()) * 100;
  }
}
