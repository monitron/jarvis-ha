const Marionette = require('backbone.marionette');
const ThumbnailsView = require('./ThumbnailsView.js');
const ExpandedView = require('./ExpandedView.js');

module.exports = class CamerasCapabilityView extends Marionette.View {
  template() {
    return '<div class="body"></div>';
  }

  className() {
    return 'cameras-capability';
  }

  regions() {
    return {body: '.body'};
  }

  modelEvents() {
    return {'change:current-camera': 'render'};
  }
  
  onRender() {
    if(this.model.has('current-camera')) {
      this.showChildView('body', new ExpandedView({model: this.model}));
    } else {
      this.showChildView('body', new ThumbnailsView({model: this.model}));
    }
  }
}
