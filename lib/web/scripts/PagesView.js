
const _ = require('underscore');
const Marionette = require('backbone.marionette');

module.exports = class PagesView extends Marionette.View {
  template = Templates['pages'];

  defaults() {
    return {
      fullSize: false
    };
  }

  regions() {
    return {
      page: '.page'
    };
  }

  ui() {
    return {
      pageSelect: '.select li'
    };
  }

  events() {
    return {
      'click @ui.pageSelect': 'onClickPageSelect'
    };
  }

  modelEvents() {
    return {
      'change:page': 'render'
    };
  }

  serializeData() {
    return {
      page:     this.model.get('page'),
      pages:    this.model.pages(),
      fullSize: this.options.fullSize
    };
  }

  onRender() {
    const page = _.findWhere(this.model.pages(), {id: this.model.get('page')});
    this.showChildView('page', page.view());
  }

  onClickPageSelect(ev) {
    const id = $(ev.target).data('id');
    this.model.set('page', id);
  }
}
