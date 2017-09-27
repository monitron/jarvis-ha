const _ = require('underscore');
const [Capability] = require('../../Capability.js');
const MediaCapabilityView = require('./MediaCapabilityView.js');

module.exports = class MediaCapability extends Capability {
  name = 'Media';
  icon = 'play-circle';
  view = MediaCapabilityView;

  initialize(attrs, options) {
    super.initialize(attrs, options);
    const firstZone = this.get('zones')[0];
    if(firstZone != null) this.set('zone', firstZone.id);
  };

  currentZoneConfig() {
    if(!this.has('zone')) return {};
    return _.findWhere(this.get('zones'), {id: this.get('zone')});
  }

  currentSource() {
    if(!this.has('zone')) return undefined;
    const state = this.currentZoneState();
    const sourceId = state.basics.mediaSource;
    if(sourceId == null) return undefined;
    return _.findWhere(state.sources, {id: sourceId});
  }

  currentZoneState() {
    if(!this.has('zone')) return {};
    return this.get('state').zones[this.get('zone')];
  }

  currentVolume() {
    if(!this.has('zone')) return undefined;
    const state = this.currentZoneState();
    if(state.basics.volume != null) {
      return state.basics.volume;
    } else {
      return 0;
    }
  }

  currentMute() {
    if(!this.has('zone')) return undefined;
    return !!this.currentZoneState().basics.mute;
  }
  
  zoneChoices() {
    return this.get('zones').map((zone) => _.pick(zone, ['id', 'name']));
  }

  sourceChoices() {
    if(!this.has('zone')) return [];
    return this.currentZoneState().sources.map(
      (source) => _.defaults({}, source, {icon: 'question-circle'}));
  }

  setCurrentZoneSource(source) {
    return this.sendCommand('setZoneSource',
                            {zone: this.get('zone'), source: source});
  }

  setCurrentZonePower(power) {
    return this.sendCommand('setZonePower',
                            {zone: this.get('zone'), power: power});
  }

  toggleCurrentZoneMute() {
    const mute = !this.currentMute();
    return this.sendCommand('setZoneMute',
                            {zone: this.get('zone'), mute: mute});
  }

  setCurrentZoneVolume(vol) {
    return this.sendCommand('setZoneVolume',
                            {zone: this.get('zone'), volume: vol});
  }
}
