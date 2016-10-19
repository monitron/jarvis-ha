
const _ = require('underscore');
const ControlBodyView = require('./ControlBodyView.js');
const SliderView = require('./SliderView.js');

module.exports = class DoorControlBodyView extends ControlBodyView {
  template = Templates['controls/door'];

  regions() { return {lock: '.lock'}; }
  ui() { return {text: '.text .display'}; }

  className() { 
    const classNames = [super.className(), 'door-control'];
    if(this.hasLock()) classNames.push('with-lock');
    return classNames.join(' ');
  }

  statusLookup = [ // undefined means unknown; null means not present
      {locked: undefined, open: undefined, text: 'Unknown'},
      {locked: undefined, open: null,      text: 'Unknown'},
      {locked: undefined, open: false,     text: 'Closed/?'},
      {locked: undefined, open: true,      text: 'Open/?'},
      {locked: null,      open: undefined, text: 'Unknown'},
      {locked: null,      open: null,      text: 'Unknown'},
      {locked: null,      open: false,     text: 'Closed'},
      {locked: null,      open: true,      text: 'Open'},
      {locked: false,     open: undefined, text: 'Unlocked/?'},
      {locked: false,     open: null,      text: 'Unlocked'},
      {locked: false,     open: true,      text: 'Open'},
      {locked: false,     open: false,     text: 'Unlocked'},
      {locked: true,      open: undefined, text: 'Locked/?'},
      {locked: true,      open: null,      text: 'Locked'},
      {locked: true,      open: true,      text: 'Locked Open'},
      {locked: true,      open: false,     text: 'Locked'}];

  serializeData() {
    return {
      hasLock: this.hasLock()
    };
  }

  onRender() {
    if(this.hasLock()) {
      const lockSliderView = new SliderView({
        detents: [
          {position: 0,   icon: 'lock',       key: 'locked'},
          {position: 100, icon: 'unlock-alt', key: 'unlocked'},
        ],
        discrete: true,
        qualitative: true,
        value: this.lockSliderValue()
      });
      this.listenTo(lockSliderView, 'value:change',
                    (val) => this.onLockSliderInput(val));
      this.showChildView('lock', lockSliderView);
    }
    this.updateText();
  }

  onStateChange() {
    this.updateText();
    if(this.hasLock())
      this.getChildView('lock').setValue(this.lockSliderValue());
  }

  onLockSliderInput(newValue) {
    if(newValue == 'locked') {
      this.model.sendCommand('lock');
    } else {
      this.model.sendCommand('unlock');
    }
  }

  updateText() {
    const state = this.model.get('state')
    const statusDetails = _.findWhere(this.statusLookup, {
      locked: state.hasLock ? state.locked : null,
      open:   state.hasSensor ? state.open : null
    });
    this.ui.text.text(statusDetails.text);
  }

  hasLock() {
    return this.model.get('state').hasLock;
  }

  lockSliderValue() {
    const state = this.model.get('state');
    if(state.locked === true) {
      return 'locked';
    } else if(state.locked === false) {
      return 'unlocked';
    } else {
      return undefined;
    }
  }
}
