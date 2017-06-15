const _ = require('underscore');
const Marionette = require('backbone.marionette');

const util = require('../../util.coffee');

module.exports = class ThumbnailsView extends Marionette.View {
  template = Templates['capabilities/cameras/thumbnails'];

  className() {
    return 'thumbnails';
  }

  events() {
    return {
      'click li': 'onCameraClick'
    };
  }

  initialize() {
    this._refresh = setInterval(this.refreshImages.bind(this),
      this.model.get('thumbnailStillInterval') * 1000);
  }

  onRender() {
    _.defer(() => this.refreshImages());
  }

  refreshImages() {
    this.model.cameras().forEach(function(camera) {
      const canvas = this.$(`li[data-id="${camera.id}"] canvas`)[0];
      util.loadImageOntoCanvas(canvas, camera.stillURI, camera.aspectRatio);
    }.bind(this));
  }
  
  serializeData() {
    return {cameras: this.model.cameras()};
  }

  onCameraClick(ev) {
    const id = $(ev.target).closest('li').data('id');
    this.model.set('current-camera', id);
  }

  onBeforeDestroy() {
    clearTimeout(this._refresh);
  }
}
