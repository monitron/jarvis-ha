const _ = require('underscore');
const moment = require('moment');
const [Capability] = require('../../Capability.js');
const PeopleSummaryCardView = require('./PeopleSummaryCardView.js');

module.exports = class PeopleCapability extends Capability {
  name = 'People';
  icon = 'user';
  cardViews = {
    summary: PeopleSummaryCardView
  };

  initialize(attrs, options) {
    super.initialize(attrs, options);
    this.addCard({
      type: 'summary',
      priority: 'low'
    });
  }

  titleForSummaryCard() {
    const people = this.get('state').people;
    const validPeople = this.validPeople();
    const home = _.filter(validPeople, (person) => person.occupancy.state);
    if(home.length == people.length) {
      return "Everyone is home";
    } else if(people.length - home.length == 1) {
      const away = _.find(validPeople, (person) => !person.occupancy.state);
      return `Everyone but ${away.name} is home`;
    } else if(home.length == 0) {
      return "No one is home";
    } else if(home.length == 1) {
      return `${home[0].name} is home`;
    } else {
      return `${home.length} people are home`;
    }
  }

  peopleForSummaryCard() {
    // Sort people by last state change, unknown at the bottom
    const people = _.sortBy(this.validPeople(), function(person) {
      if(person.occupancy.time != null) {
        return -moment(person.occupancy.time).unix();
      } else {
        return 0;
      }
    });
    return people.map(function(person) {
      var description = person.occupancy.state ? 'home' : 'away';
      if(person.occupancy.time != null) {
        const time = moment(person.occupancy.time);
        description = `${description} for ${time.fromNow(true)}`;
      }
      if(!person.occupancy.confident) description = `probably ${description}`;
      description = description.charAt(0).toUpperCase() + description.slice(1);
      return {
        name: person.name,
        isAway: !person.occupancy.state,
        description: description
      }
    });
  }

  validPeople() {
    const people = this.get('state').people;
    return _.filter(people, (person) => person.occupancy != null);
  }
}
