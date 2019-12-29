const Marionette = require('backbone.marionette');
const ThumbnailsView = require('./ThumbnailsView.js');

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
      const liveView = this.model.createLiveView(
        this.model.get('current-camera'),
        {
          onClick: () => this.model.unset('current-camera')
        });
      this.showChildView('body', liveView);
    } else {
      this.showChildView('body', new ThumbnailsView({model: this.model}));
    }
  }
}
