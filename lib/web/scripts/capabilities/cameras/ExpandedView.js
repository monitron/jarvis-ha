const _ = require('underscore');
const Marionette = require('backbone.marionette');

const util = require('../../util.coffee');

module.exports = class ExpandedView extends Marionette.View {
  template = Templates['capabilities/cameras/expanded'];

  className() {
    return 'expanded';
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
    return _.findWhere(this.model.cameras(),
                       {id: this.model.get('current-camera')});
  }

  onClick() {
    this.model.unset('current-camera');
  }

  onBeforeDestroy() {
    clearTimeout(this._refresh);
  }
}
