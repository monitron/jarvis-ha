const _ = require('underscore');
const Marionette = require('backbone.marionette');
const d3 = require('d3');

module.exports = class TemperatureChartView extends Marionette.View {
  template = () => Templates['capabilities/weather/temperature-chart'];
  className() { return 'temperature-chart'; }

  options() {
    return {
      height: 90,           // pixels
      hourWidth: 70,        // pixels
      tempDomainPadding: 5, // degrees
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
    const height = this.options.height;
    const width = (this.model.length + 1) * this.options.hourWidth;
    this.ui.svg.attr('height', height).attr('width', width);
    const valueDomain = d3.extent(this.model);
    valueDomain[0] -= this.options.tempDomainPadding;
    valueDomain[1] += this.options.tempDomainPadding;
    const y = d3.scaleLinear()
      .rangeRound([height, 0])
      .domain(valueDomain);
    const x = d3.scaleLinear()
      .domain([0, this.model.length - 1])
      .range([0, width]);
    const area = d3.area()
      .x((d, i) => x(i))
      .y1((d) => y(d))
      .y0(y(valueDomain[0]));
    svg.append('path')
      .datum(this.model)
      .attr('d', area);
  }
}
