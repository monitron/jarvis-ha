
const Marionette = require('backbone.marionette');

module.exports = class PeopleSummaryCardView extends Marionette.View {
  template = Templates['capabilities/people/summary-card'];

  initialize() {
    const render = () => {if(this.model.collection != null) this.render()};
    this.listenTo(this.model.capability(), 'change', render);
    this._interval = setInterval(render, 60000); // Update relative times
  }

  serializeData() {
    const cap = this.model.capability();
    return {
      title: cap.titleForSummaryCard(),
      people: cap.peopleForSummaryCard()
    }
  }

  onBeforeDestroy() {
    clearInterval(this._interval);
  }
}
