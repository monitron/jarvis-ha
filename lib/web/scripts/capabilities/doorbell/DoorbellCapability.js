
const _ = require('underscore');
const moment = require('moment');
const [Capability] = require('../../Capability.js');
const DoorbellRangView = require('./DoorbellRangView.js');

module.exports = class DoorbellCapability extends Capability {
  name = 'Doorbell';
  icon = 'bell';

  initialize() {
    this.listenTo(this, 'change', () => this.onChange());
  }

  onChange() {
    // Are any doorbells ringing right now?
    // XXX if multiple doorbells are ringing, this will do something silly
    _.each(this.get('state').doors, (lastRing, doorId) => {
      if(moment().diff(moment(lastRing), 'seconds') <
         this.getDoorConfig(doorId).quietTime) {
        this.showRingModal(doorId);
      }
    });
  }

  showRingModal(doorId) {
    const cfg = this.getDoorConfig(doorId);
    const view = new DoorbellRangView({model: this, doorId});
    window.app.view.showModalView(cfg.name, view);
    window.app.view.setIdle(false);
  }

  getDoorConfig(doorId) {
    return this.get('doors')[doorId];
  }
}
