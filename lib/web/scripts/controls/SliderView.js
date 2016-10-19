
const Marionette = require('backbone.marionette');
const _ = require('underscore');

module.exports = class SliderView extends Marionette.View {
  template = Templates['controls/slider'];

  // options = {
  //   value: 0, // number or string corresponding to detent key
  //   detents: [],
  //   discrete: false
  //   qualitative: false  // if true, no trail will be rendered
  // };
  // Detent options:
  //   key:      corresponds to current value
  //   position: number 0 to 100
  //   label:    string

  className() { return 'slider'; }

  ui() {
    return {
      track:       '.track',
      handle:      '.handle',
      trail:       '.trail',
      handleLabel: '.handle .label',
      detents:     '.detent',
      bounds:      '.bounds'
    };
  }

  events() {
    return {
      'touchstart @ui.bounds': 'onTouchStart',
      'touchend   @ui.bounds': 'onTouchEnd',
      'touchmove  @ui.bounds': 'onTouchMove',
      'mousedown  @ui.bounds': 'onMouseDown',
      'mouseup    @ui.bounds': 'onMouseUp',
      'mousemove  @ui.bounds': 'onMouseMove',
      'mouseleave @ui.bounds': 'onMouseLeave'
    };
  }

  serializeData() {
    return {
      detents: this.getOption('detents'),
      quantitative: !this.getOption('qualitative')
    };
  }

  initialize() {
    this.value = this.getOption('value');
  }

  onRender() {
    _.defer(() => this.indicateValue());
  }

  onTouchStart(event) {
    this.swiping = true;
    const touch = event.originalEvent.touches[0];
    this.swipeOrigin = [touch.screenX, touch.screenY];
    this.swipeInitialOffset = parseInt(this.ui.handle.css('left'));
    this.swipeEstablished = false;
  }

  onTouchEnd(event) {
    if(this.swiping) {
      this.swiping = false;
      // Ignore touches that never moved (they're clicks)
      if(this.swipeEstablished) {
        const newVal = this.positionToValue(this.swipePos);
        if(newVal != this.value) {
          this.trigger('value:change', newVal);
        }
      }
    }
  }

  onTouchMove(event) {
    if(this.swiping) {
      const touch = event.originalEvent.touches[0];
      const swipeDelta = [touch.screenX - this.swipeOrigin[0],
                          touch.screenY - this.swipeOrigin[1]];
      // Cancel a new swipe if it isn't going horizontally
      if(!this.swipeEstablished) {
        if(Math.abs(swipeDelta[1]) > Math.abs(swipeDelta[0])) {
          this.indicateValue();
          this.swiping = false;
          return;
        }
        this.swipeEstablished = true;
      }
      event.preventDefault(); // This doesn't appear to be scrolling.
      const offset = this.swipeInitialOffset + swipeDelta[0];
      this.swipePos = this.offsetToPosition(offset);
      this.indicateValue(this.positionToValue(this.swipePos), true);
    }
  }

  onMouseDown(event) {
    this.dragging = true;
    this.dragOrigin = event.screenX;
    this.dragInitialOffset = parseInt(this.ui.handle.css('left'));
  }

  onMouseMove(event) {
    if(this.dragging) {
      const offset = this.dragInitialOffset + (event.screenX - this.dragOrigin);
      this.dragPos = this.offsetToPosition(offset);
      this.indicateValue(this.positionToValue(this.dragPos), true);
    }
  }

  onMouseUp(event) {
    if(this.dragging) {
      this.dragging = false;
      const offset = event.offsetX - (this.ui.handle.width() / 2);
      const newVal = this.positionToValue(this.offsetToPosition(offset));
      if(newVal != this.value) {
        this.trigger('value:change', newVal);
      }
    }
  }

  onMouseLeave(event) {
    if(this.dragging) { // Cursor wandered away; cancel drag
      this.indicateValue();
      this.dragging = false;
    }
  }

  setValue(newValue) {
    this.value = newValue;
    this.indicateValue();
  }

  indicateValue(tempValue = null, dragging = false) {
    var position, label, icon;
    const isTemp = tempValue != null;
    const value = isTemp ? tempValue : this.value;
    if(_.isString(value)) {
      const detent = _.findWhere(this.getOption('detents'), {key: value});
      ({position, label, icon} = detent);
    } else {
      position = value;
      label = `${Math.round(value)}%`;
    }
    if(_.isFinite(position)) {
      this.ui.handle.removeClass('invalid');
      this.ui.handle.css('left', this.positionToOffset(position));
    } else {
      this.ui.handle.addClass('invalid');
    }
    if(!dragging) {
      if(!this.getOption('qualitative')) {
        this.ui.trail.css('width', `${position}%`);
        // Make sure all detents are visible over trail
        for(const detent of this.getOption('detents')) {
          this.ui.detents.filter(`[data-position="${detent.position}"]`)
            .toggleClass('reversed', detent.position < position);
        }
      }
    }
    if(icon != null) {
      this.ui.handleLabel.html(`<i class="fa fa-${icon}"></i>`);
    } else {
      this.ui.handleLabel.text(label);
    }
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
        if(Math.abs(detent.position - position) <= 8) {
          return (detent.key != null) ? detent.key : detent.position;
        }
      }
      return position;
    }
  }

  offsetToPosition(offset) {
    return Math.max(0, Math.min(100, (offset / this.trackWidth()) * 100));
  }

  positionToOffset(position) {
    return (position / 100.0) * this.trackWidth();
  }

  trackWidth() {
    return this.ui.track.width() - this.ui.handle.width();
  }
}
