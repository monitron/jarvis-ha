const _ = require('underscore');
const Marionette = require('backbone.marionette');
const d3 = require('d3');

module.exports = class TemperatureChartView extends Marionette.View {
  template = () => Templates['capabilities/weather/pop-chart'];
  className() { return 'pop-chart'; }

  options() {
    return {
      height: 82,           // pixels
      hourWidth: 74,        // pixels. Why 74 and not 70? It's a mystery
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
    const width = this.model.length * this.options.hourWidth;
    this.ui.svg.attr('height', height).attr('width', width);
    const y = d3.scaleLinear()
      .rangeRound([height, 0])
      .domain([0, 100]);
    const x = d3.scaleBand()
      .rangeRound([0, width])
      .padding(0)
      .domain(_.range(this.model.length))
    svg.selectAll('.bar')
      .data(this.model)
      .enter()
      .append('rect')
      .attr('class', 'bar')
      .attr('x', (d, i) => x(i))
      .attr('y', (d) => y(d))
      .attr('width', x.bandwidth())
      .attr('height', (d) => height - y(d))
  }
}
