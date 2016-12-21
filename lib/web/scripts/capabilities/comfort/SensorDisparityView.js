
const _ = require('underscore');
const Marionette = require('backbone.marionette');
const d3 = require('d3');

module.exports = class SensorDisparityView extends Marionette.View {
  template = () => '<svg width="100%" height="100%"></svg>';
  className() { return 'comfort-sensor-disparity'; }

  defaults = {
    minDomain: [-5, 5]
  };

  ui() {
    return {
      svg: 'svg'
    };
  }

  onRender() {
    _.defer(() => this.renderChart());
  }

  renderChart() {
    console.log(this.model);
    const svg = d3.select(this.ui.svg[0]);
    const margin = {top: 20, right: 20, bottom: 20, left: 20};
    const width = this.ui.svg.width() - margin.left - margin.right;
    const height = this.ui.svg.height() - margin.top - margin.bottom;
    console.log(`width ${width} height ${height}`);
    const y = d3.scaleBand()
      .rangeRound([0, height])
      .padding(0.1)
      .domain(_.pluck(this.model.rooms, 'room'));
    const x = d3.scaleLinear()
      .rangeRound([0, width])
      .domain(d3.extent(_.pluck(this.model.rooms, 'difference').concat(
        this.options.minDomain)));
    const g = svg.append('g')
      .attr('transform', `translate(${margin.left}, ${margin.top})`);
    g.selectAll('.bar')
      .data(this.model.rooms)
      .enter()
      .append('rect')
      .attr('class', 'bar')
      .attr('x', (d) => x(d.difference < 0 ? d.difference : 0))
      .attr('y', (d) => y(d.room))
      .attr('width', (d) => d.difference < 0 ? x(0) - x(d.difference) :
           x(d.difference) - x(0))
      .attr('height', y.bandwidth())
  }
}
