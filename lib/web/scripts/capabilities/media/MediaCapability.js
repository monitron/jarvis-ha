const _ = require("underscore");
const [Capability] = require("../../Capability.js");
const MediaCapabilityView = require("./MediaCapabilityView.js");
const NowPlayingCardView = require("./NowPlayingCardView.js");

module.exports = class MediaCapability extends Capability {
  name = "Media";
  icon = "play-circle";
  view = MediaCapabilityView;
  cardViews = {
    nowPlaying: NowPlayingCardView,
  };

  defaults() {
    return {
      stations: {},
    };
  }

  initialize(attrs, options) {
    super.initialize(attrs, options);
    const firstZone = this.get("zones")[0];
    if (firstZone != null) this.set("zone", firstZone.id);
    this.updateCards();
    this.listenTo(this, "change update reset", () => this.updateCards());
  }

  stationConfig() {
    const station = window.app.get("station");
    if (station == null) return {};
    return this.get("stations")[station] || {};
  }

  // TODO The following is insane and should be refactored so Zone is a first
  //      class object client-side

  currentZoneConfig() {
    if (!this.has("zone")) return {};
    return this.zoneConfig(this.get("zone"));
  }

  zoneConfig(zoneId) {
    return _.findWhere(this.get("zones"), { id: zoneId });
  }

  currentSource() {
    if (!this.has("zone")) return undefined;
    return this.currentSourceForZone(this.get("zone"));
  }

  currentSourceForZone(zoneId) {
    const state = this.zoneState(zoneId);
    let sourceId = "single";
    if (!this.zoneIsSingleSource(zoneId)) {
      sourceId = state.basics.mediaSource;
      if (sourceId == null) return undefined;
    }
    return _.findWhere(state.sources, { id: sourceId });
  }

  currentZoneIsSingleSource() {
    return this.zoneIsSingleSource(this.get("zone"));
  }

  zoneIsSingleSource(zoneId) {
    return this.zoneConfig(zoneId)["single-source"];
  }

  currentZoneHasVolumeControls() {
    return _.any(this.currentZoneConfig().connections, (conn) =>
      _.includes(conn.aspects, "volume")
    );
  }

  currentZoneIsOn() {
    if (!this.has("zone")) return false;
    return this.zoneIsOn(this.get("zone"));
  }

  currentZoneState() {
    if (!this.has("zone")) return {};
    return this.zoneState(this.get("zone"));
  }

  zoneState(zoneId) {
    return this.get("state").zones[zoneId];
  }

  zoneIsOn(zoneId) {
    const state = this.zoneState(zoneId);
    const hasOnOff = _.any(this.zoneConfig(zoneId).connections, (conn) =>
      _.includes(conn.aspects, "powerOnOff")
    );
    if (hasOnOff) {
      return state.basics.powerOnOff;
    } else {
      return state.basics.source != null;
    }
  }

  currentVolume() {
    if (!this.has("zone")) return undefined;
    const state = this.currentZoneState();
    if (state.basics.volume != null) {
      return state.basics.volume;
    } else {
      return 0;
    }
  }

  currentMute() {
    if (!this.has("zone")) return undefined;
    return !!this.currentZoneState().basics.mute;
  }

  zoneChoices() {
    return this.get("zones").map((zone) => _.pick(zone, ["id", "name"]));
  }

  sourceChoices() {
    if (!this.has("zone")) return [];
    return this.currentZoneState().sources.map((source) =>
      _.defaults({}, source, { icon: "question-circle" })
    );
  }

  setCurrentZoneSource(source) {
    return this.sendCommand("setZoneSource", {
      zone: this.get("zone"),
      source: source,
    });
  }

  setCurrentZonePower(power) {
    return this.sendCommand("setZonePower", {
      zone: this.get("zone"),
      power: power,
    });
  }

  toggleCurrentZoneMute() {
    const mute = !this.currentMute();
    return this.sendCommand("setZoneMute", {
      zone: this.get("zone"),
      mute: mute,
    });
  }

  setCurrentZoneVolume(vol) {
    return this.sendCommand("setZoneVolume", {
      zone: this.get("zone"),
      volume: vol,
    });
  }

  pauseCurrentSource(zoneId) {
    if (zoneId == null) zoneId = this.get("zone");
    return this.sendCommand("sourcePause", {
      zone: zoneId,
      source: this.currentSourceForZone(zoneId).id,
    });
  }

  playCurrentSource(zoneId) {
    if (zoneId == null) zoneId = this.get("zone");
    return this.sendCommand("sourcePlay", {
      zone: zoneId,
      source: this.currentSourceForZone(zoneId).id,
    });
  }

  stopCurrentSource(zoneId) {
    if (zoneId == null) zoneId = this.get("zone");
    return this.sendCommand("sourceStop", {
      zone: zoneId,
      source: this.currentSourceForZone(zoneId).id,
    });
  }

  zonesForNowPlayingCard() {
    const matches = _.filter(this.get("zones"), (zone) => {
      const state = this.zoneState(zone.id);
      return (
        this.zoneIsOn(zone.id) ||
        (zone["single-source"] &&
          !!state.sources[0] &&
          state.sources[0] &&
          !_.isEmpty(state.sources[0].transport))
      );
    });
    return _.map(matches, (zone) => {
      const source = this.currentSourceForZone(zone.id);
      return {
        id: zone.id,
        name: zone.name || zone.id,
        sourceName: !zone["single-source"] && source && source.name,
        metadata: source && source.metadata,
        transportState: source && source.transport && source.transport.state,
      };
    });
  }

  updateCards() {
    const currentCard = this.cardWhere({ type: "nowPlaying" });
    if (this.zonesForNowPlayingCard().length > 0) {
      if (currentCard == null)
        this.addCard({
          type: "nowPlaying",
          priority: "medium",
        });
    } else {
      this.removeCardsWhere({ type: "nowPlaying" });
    }
  }

  shortcuts() {
    const station = this.stationConfig();
    if (station && !_.isEmpty(station.homeZones)) {
      return _.compact([
        {
          id: "media-here",
          priority: 100,
          title: "Media Here",
          icon: "map-marker",
          contents: station.homeZones.map((zone) => {
            const config = this.zoneConfig(zone);
            if (config != null)
              return {
                id: zone,
                title: config.name,
                icon: "play-circle",
                link: true,
                onClick: () => {
                  this.set("zone", zone);
                  this.visit();
                },
              };
          }),
        },
      ]);
    } else {
      return [];
    }
  }
};
