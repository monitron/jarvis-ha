const Marionette = require("backbone.marionette");
const SliderView = require("../../SliderView.js");

module.exports = class MediaCapabilityView extends Marionette.View {
  template = Templates["capabilities/media/media"];

  className() {
    return "media-capability";
  }

  modelEvents() {
    return {
      change: "render",
    };
  }

  regions() {
    return {
      volumeSlider: ".volume .control",
    };
  }

  ui() {
    return {
      zone: ".zone",
      sourceSelect: ".source .select",
      offButton: ".off-button",
      muteButton: ".mute-button",
      pauseButton: ".pause-button",
      playButton: ".play-button",
      volDownButton: ".vol-down-button",
      volUpButton: ".vol-up-button",
    };
  }

  events() {
    return {
      "click @ui.zone": "chooseZone",
      "click @ui.sourceSelect": "chooseSource",
      "click @ui.offButton": "turnOff",
      "click @ui.muteButton": "toggleMute",
      "click @ui.pauseButton": "pauseSource",
      "click @ui.playButton": "playSource",
      "click @ui.volDownButton": "lowerVolume",
      "click @ui.volUpButton": "raiseVolume",
    };
  }

  onRender() {
    if (this.model.currentZoneHasVolumeControls()) {
      const sliderView = new SliderView({
        detents: [],
        value: this.model.currentVolume(),
        disabled: this.model.currentMute() || !this.model.currentZoneIsOn(),
      });
      this.listenTo(sliderView, "value:change", (val) =>
        this.changeVolume(val)
      );
      this.showChildView("volumeSlider", sliderView);
    }
  }

  serializeData() {
    const source = this.model.currentZoneIsOn()
      ? this.model.currentSource()
      : undefined;
    return {
      zoneName: this.model.currentZoneConfig().name,
      hasMultipleSources: !this.model.currentZoneIsSingleSource(),
      hasVolumeControls: this.model.currentZoneHasVolumeControls(),
      sourceName: this.model.currentZoneIsOn() && source && source.name,
      isOff: !this.model.currentZoneIsOn(),
      isMuted: this.model.currentMute(),
      metadata: source && source.metadata,
      isPlaying: source && source.transport && source.transport.state == "play",
      isPaused: source && source.transport && source.transport.state == "pause",
    };
  }

  chooseZone() {
    const callback = (choice) => this.model.set("zone", choice);
    window.app.pick(
      callback,
      "Choose Media Zone",
      this.model.zoneChoices(),
      this.model.get("zone")
    );
  }

  chooseSource() {
    const callback = (choice) => this.model.setCurrentZoneSource(choice);
    const currentSource = this.model.currentZoneIsOn()
      ? this.model.currentSource()
      : undefined;
    window.app.pick(
      callback,
      "Change Source",
      this.model.sourceChoices(),
      currentSource && currentSource.id
    );
  }

  turnOff() {
    this.model.setCurrentZonePower(false);
  }

  changeVolume(newVol) {
    this.model.setCurrentZoneVolume(newVol);
  }

  lowerVolume() {
    this.model.lowerCurrentZoneVolume();
  }

  raiseVolume() {
    this.model.raiseCurrentZoneVolume();
  }

  toggleMute() {
    this.model.toggleCurrentZoneMute();
  }

  playSource() {
    this.model.playCurrentSource();
  }

  pauseSource() {
    this.model.pauseCurrentSource();
  }
};
