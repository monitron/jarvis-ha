const _ = require('underscore');
const Marionette = require('backbone.marionette');

module.exports = class NowPlayingCardView extends Marionette.View {
  template = Templates['capabilities/media/now-playing-card'];

  ui() {
    return {
      zoneName: '.zone .name',
      pause: '.pause-button',
      play: '.play-button',
      stop: '.stop-button'
    };
  }

  events() {
    return {
      'click @ui.zoneName': 'onClickZoneName',
      'click @ui.pause':    'onClickPause',
      'click @ui.play':     'onClickPlay',
      'click @ui.stop':     'onClickStop'
    };
  }

  initialize() {
    this.listenTo(this.model.capability(), 'change',
                  () => {if(this.model.collection != null) this.render()});
  }

  serializeData() {
    const zones = this.model.capability().zonesForNowPlayingCard();
    let title = "Now playing on ";
    if(zones.length == 1) {
      title = title + zones[0].name;
    } else {
      title = title + `${zones.length} zones`;
    }
    return {
      title: title,
      zones: zones.map((zone) => {
        return {
          id: zone.id,
          name: zone.name,
          sourceName: zone.sourceName,
          metadata: zone.metadata,
          canPlay: zone.transportState == 'pause',
          canPause: zone.transportState == 'play',
          canStop: _.contains(['pause', 'play'], zone.transportState)
        };
      })
    };
  }

  onClickZoneName(event) {
    const id = $(event.target).closest('.zone').data('id');
    const cap = this.model.capability();
    cap.set('zone', id);
    cap.visit();
  }

  onClickPause(event) {
    const id = $(event.target).closest('.zone').data('id');
    this.model.capability().pauseCurrentSource(id);
  }

  onClickPlay(event) {
    const id = $(event.target).closest('.zone').data('id');
    this.model.capability().playCurrentSource(id);
  }

  onClickStop(event) {
    const id = $(event.target).closest('.zone').data('id');
    this.model.capability().stopCurrentSource(id);
  }
}
