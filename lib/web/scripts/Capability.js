const _ = require('underscore');
const [baseCapability, baseCapabilities] = require('../../Capability.coffee');

class Capability extends baseCapability {
  initialize(attrs, options) {
    super.initialize(attrs, options);
    this._valid = this.get('valid');
    this._tasks = [];
  }

  addTask(promise) {
    this._tasks.push(promise);
    this.trigger('task:started');
    if(this._tasks.length == 1) this.trigger('task:some');
    promise.done(() => this.trigger('task:done', promise));
    promise.fail(() => this.trigger('task:fail', promise));
    promise.always(() => {
      this._tasks = _.without(this._tasks, promise);
      if(_.isEmpty(this._tasks)) this.trigger('task:none');
    });
  }

  sendCommand(commandId, params = {}) {
    const promise = $.ajax({
      url: `api/capabilities/${this.id}/commands/${commandId}`,
      type: 'POST',
      data: params
    });
    this.addTask(promise);
    return promise;
  }
}
  
class Capabilities extends baseCapabilities {
  url = 'api/capabilities';

  model(attrs, options) {
    const klass = require('./capabilities/index.js')[attrs.id];
    return new klass(attrs, options);
  }
}

module.exports = [Capability, Capabilities];
