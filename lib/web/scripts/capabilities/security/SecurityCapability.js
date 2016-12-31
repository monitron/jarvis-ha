const _ = require('underscore');
const [Capability] = require('../../Capability.js');
const SecurityCapabilityView = require('./SecurityCapabilityView.js');

module.exports = class ComfortCapability extends Capability {
  name = 'Security';
  icon = 'shield';
  view = SecurityCapabilityView;

  modes() {
    const currentMode = this.get('state').mode;
    return _.map(this.get('modes'), (mode, modeId) => {
      return {
        id: modeId,
        icon: mode.icon,
        name: mode.name,
        current: modeId == currentMode
      };
    });
  }

  ruleStatus() {
    const ruleStatus = this.get('state').rules;
    const stateValues = _.pluck(_.values(ruleStatus), 'state');
    let overall = 'ok';
    let overallIcon = 'check-circle';
    let overallText = 'Everything looks OK.';
    if(_.contains(stateValues, true)) {
      overall = 'triggered';
      overallIcon = 'exclamation-circle';
      overallText = 'There are some problems:';
    } else if(_.contains(stateValues, null)) {
      overall = 'unknown';
      overallIcon = 'question-circle';
      overallText = 'Some states are unknown:';
    }
    // XXX Order these by severity
    const problems = _.chain(ruleStatus)
      .map((rule, ruleId) => {
        return {
          id: ruleId,
          state: rule.state,
          icon: rule.state === null ? 'question-circle-o' : 'excalamation-circle-o',
          type: rule.state === null ? 'unknown' : 'triggered',
          description: rule.description
        };
      }).select((rule) => rule.state !== false)
      .value();
    return {
      overall: overall,
      icon: overallIcon,
      text: overallText,
      problems: problems
    };
  }
}
