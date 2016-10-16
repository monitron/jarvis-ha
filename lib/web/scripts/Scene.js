const _ = require('underscore');
const [baseScene, baseScenes] = require('../../Scene.coffee');

class Scene extends baseScene {
  initialize(attrs, options) {
    super.initialize(attrs, options);
    this._valid = this.get('valid');
  }

  activate() {
    return $.ajax({
      url: `/api/scenes/${this.id}/activate`,
      type: 'POST'
    });
  }
}

class Scenes extends baseScenes {
  url = '/api/scenes';
  model = Scene;
}

module.exports = [Scene, Scenes];
