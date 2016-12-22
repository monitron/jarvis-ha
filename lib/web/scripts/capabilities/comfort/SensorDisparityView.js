
const _ = require('underscore');
const Marionette = require('backbone.marionette');
const d3 = require('d3');

module.exports = class SensorDisparityView extends Marionette.View {
  template = () => '<svg width="100%"></svg>';
  className() { return 'comfort-sensor-disparity'; }

  options() {
    return {
      minDomain: [-2, 2],
      xTickInterval: 5 / 9.0
    };
  }

  ui() {
    return {
      svg: 'svg'
    };
  }

  onRender() {
    _.defer(() => this.renderChart());
  }

  renderChart() {
    const svg = d3.select(this.ui.svg[0]);
    const margin = {top: 20, right: 60, bottom: 10, left: 150};
    const width = this.ui.svg.width() - margin.left - margin.right;
    const height = 35 * this.model.rooms.length;
    this.ui.svg.attr('height', `${height + margin.top + margin.bottom}px`);
    const y = d3.scaleBand()
      .rangeRound([0, height])
      .padding(0.1)
      .domain(_.pluck(this.model.rooms, 'roomName'));
    const x = d3.scaleLinear()
      .rangeRound([0, width])
      .domain(d3.extent(_.pluck(this.model.rooms, 'difference').concat(
        this.options.minDomain)));
    const g = svg.append('g')
      .attr('transform', `translate(${margin.left}, ${margin.top})`);
    const xAxis = d3.axisTop(x)
      .tickSize(-height)
      .tickValues(this.tickValues(x.domain()));
    g.append('g')
      .attr('class', 'axis x')
      .call(xAxis);
    g.selectAll('.bar')
      .data(this.model.rooms)
      .enter()
      .append('rect')
      .attr('class', 'bar')
      .attr('x', (d) => x(d.difference < 0 ? d.difference : 0))
      .attr('y', (d) => y(d.roomName))
      .attr('width', (d) => d.difference < 0 ? x(0) - x(d.difference) :
           x(d.difference) - x(0))
      .attr('height', y.bandwidth())
    g.append('g')
      .attr('class', 'axis y')
      .call(d3.axisLeft(y));
    const valuesG = g.append('g')
      .attr('class', 'values')
      .attr('transform', `translate(${width}, 0)`);
    valuesG.selectAll('text')
      .data(this.model.rooms)
      .enter()
      .append('text')
      .attr('x', margin.right - 10)
      .attr('y', (d) => y(d.roomName) + (y.bandwidth() / 2))
      .attr('dy', '0.32em')
      .html((d) => d.formatted);
    g.append('line')
      .attr('class', 'x zero')
      .attr('x1', x(0))
      .attr('x2', x(0))
      .attr('y1', 0)
      .attr('y2', height);
  }
  
  tickValues(domain) {
    const ticks = [];
    var pos = 0;
    while(pos > domain[0]) {
      ticks.push(pos);
      pos -= this.getOption('xTickInterval');
    }
    pos = this.getOption('xTickInterval');
    while(pos < domain[1]) {
      ticks.push(pos);
      pos += this.getOption('xTickInterval');
    }
    return ticks.sort();
  }
}
