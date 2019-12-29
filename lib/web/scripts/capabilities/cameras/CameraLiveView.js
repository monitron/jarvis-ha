const _ = require('underscore');
const Marionette = require('backbone.marionette');

const util = require('../../util.coffee');

// If you want to make one of these for use outside of the cameras capability,
// please see CamerasCapability#createLiveView

module.exports = class CameraLiveView extends Marionette.View {
  template = Templates['capabilities/cameras/live'];

  className() {
    return 'camera-live';
  }

  events() {
    return {click: 'onClick'};
  }

  initialize() {
    this._refresh = setInterval(this.refreshImage.bind(this),
      this.model.get('expandedStillInterval') * 1000);
  }

  onRender() {
    _.defer(() => {
      this.$('canvas')
        .attr('width', this.$el.width())
        .attr('height', this.$el.height());
      this.refreshImage();
    });
  }

  refreshImage() {
    const canvas = this.$(`canvas`)[0];
    const aspectRatio = this.camera().aspectRatio;
    util.loadImageOntoCanvas(canvas, this.camera().stillURI, aspectRatio);
  }

  camera() {
    return _.findWhere(this.model.cameras(), {id: this.options.cameraId});
  }

  onClick() {
    if(_.isFunction(this.options.onClick)) this.options.onClick();
    this.model.unset('current-camera');
  }

  onBeforeDestroy() {
    clearTimeout(this._refresh);
  }
}
