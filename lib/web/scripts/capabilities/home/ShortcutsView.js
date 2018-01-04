const _ = require('underscore');
const Marionette = require('backbone.marionette');

module.exports = class ShortcutsView extends Marionette.View {
  template = Templates['capabilities/home/shortcuts'];

  ui() {
    return {
      shortcut: '.shortcut'
    };
  }

  events() {
    return {
      'click @ui.shortcut': 'onClickShortcut'
    }
  }
  
  className() {
    return 'shortcuts';
  }
  
  serializeData() {
    return {categories: this.model.allShortcuts()};
  }

  onClickShortcut(ev) {
    const $el = $(ev.target).closest('.shortcut');
    const shortcutId = $el.data('id');
    const categoryId = $el.closest('.category').data('id');
    const cat = _.findWhere(this.model.allShortcuts(), {id: categoryId});
    const result = _.findWhere(cat.contents, {id: shortcutId}).onClick();
    if(result != null && _.isFunction(result.then)) {
      $el.addClass('busy');
      result.then(() => $el.removeClass('busy'));
    }
  }
}
