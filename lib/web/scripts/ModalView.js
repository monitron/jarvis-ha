
const Marionette = require('backbone.marionette');

module.exports = class ModalView extends Marionette.View {
  template = Templates['modal'];

  className() {
    return 'modal';
  }

  ui() {
    return({close: '> .header .close'});
  }

  events() {
    return({'click .close': 'onClickClose'});
  }

  regions() {
    return {
      body: '.body'
    };
  }

  onRender() {
    const content = this.getOption('content');
    if(content != null) {
      this.showChildView('body', content);
      this.listenTo(content, 'destroy', () => this.destroy());
    }
  }

  serializeData() {
    return {
      title: this.getOption('title')
    };
  }

  onClickClose() {
    this.destroy();
  }
}
