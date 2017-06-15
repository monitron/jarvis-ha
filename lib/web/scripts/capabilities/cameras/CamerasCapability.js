const [Capability] = require('../../Capability.js');
const util = require('../../util.coffee');
const CamerasCapabilityView = require('./CamerasCapabilityView.js');

module.exports = class CamerasCapability extends Capability {
  name = 'Cameras';
  icon = 'video-camera';
  view = CamerasCapabilityView;

  cameras() {
    const cameras = this.get('state').cameras;
    return Object.keys(cameras).map((cameraId) => {
      const camera = Object.assign({id: cameraId}, cameras[cameraId]);
      if(camera.still) {
        camera.aspectRatio = camera.still.aspectRatio; // May be undefined
        if(camera.still.imageLocation) {
          camera.stillURI = camera.still.imageLocation;
        } else if(camera.still.imageResource) {
          camera.stillURI = util.resourceURI(camera.stillPath,
                                             camera.still.imageResource);
        }
      }
      return camera;
    });
  }
}
