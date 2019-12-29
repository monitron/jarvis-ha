const _ = require('underscore');
const [Capability] = require('../../Capability.js');
const util = require('../../util.coffee');
const CamerasCapabilityView = require('./CamerasCapabilityView.js');
const CameraLiveView = require('./CameraLiveView.js');

module.exports = class CamerasCapability extends Capability {
  name = 'Cameras';
  icon = 'video-camera';
  view = CamerasCapabilityView;

  initialize() {
    this.listenTo(window.app, 'idle:enter', () => this.unset('current-camera'));
  }
  
  cameras() {
    const cameras = this.get('state').cameras;
    return Object.keys(cameras).map((cameraId) => {
      const camera = Object.assign({id: cameraId}, cameras[cameraId]);
      if(camera.still) {
        camera.aspectRatio = camera.still.aspectRatio; // May be undefined
        if(camera.still.imageResource) {
          camera.stillURI = util.resourceURI(camera.stillPath,
                                             camera.still.imageResource);
        } else if(camera.still.imageLocation) {
          camera.stillURI = camera.still.imageLocation;
        }
      }
      return camera;
    });
  }

  // options:
  //   onClick: a method to call on click of the entire image
  createLiveView(cameraId, options = {}) {
    return new CameraLiveView(_.defaults(options, {model: this, cameraId}));
  }
}
