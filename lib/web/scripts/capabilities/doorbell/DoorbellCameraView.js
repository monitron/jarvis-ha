const _ = require('underscore');
const Marionette = require('backbone.marionette');

const util = require('../../util.coffee');

module.exports = class ExpandedView extends Marionette.View {
  template = () => "<canvas></canvas>";

  className() {
    return 'doorbell-camera';
  }

  initialize() {
    this._refresh = setInterval(this.refreshImage.bind(this),
      this.options.stillInterval * 1000;
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
    util.loadImageOntoCanvas(this.$(`canvas`)[0],
                             this.options.stillURI,
                             this.options.aspectRatio);
  }

  onBeforeDestroy() {
    clearTimeout(this._refresh);
  }
}
