const _ = require('underscore');
const Marionette = require('backbone.marionette');
const d3 = require('d3');

module.exports = class TemperatureChartView extends Marionette.View {
  template = Templates['capabilities/weather/temperature-chart'];
  className() { return 'temperature-chart'; }

  options() {
    return {
      height: 90,           // pixels
      hourWidth: 74,        // pixels
      tempDomainPadding: 5, // degrees
    };
  }

  ui() {
    return {
      svg: 'svg'
    };
  }

  serializeData() {
    return {
      edgeWidth:  this.options.hourWidth / 2,
      bodyLeft:   this.options.hourWidth,
      bodyWidth:  this.options.hourWidth * (this.model.length - 1),
      bodyRight:  this.options.hourWidth * (this.model.length + 0.5),
      height:     this.options.height,
      width:      this.options.hourWidth * (this.model.length + 2),
      halfHeight: this.options.height / 2
    };
  }

  onRender() {
    _.defer(() => this.renderChart());
  }

  renderChart() {
    const data = [this.model[0]].concat(this.model, this.model.slice(-1));
    const svg = d3.select(this.ui.svg[0]);
    const height = this.options.height;
    const width = data.length * this.options.hourWidth;
    const svgWidth = this.model.length * this.options.hourWidth;
    this.ui.svg.attr('height', height).attr('width', svgWidth);
    // Chart is one lane too wide so we can fill the gutter of half a lane
    // on each end. Shift entire chart over half a lane to the left.
    const g = svg.append('g')
      .attr('transform', `translate(${this.options.hourWidth / -2}, 0)`)
      .attr('mask', 'url(#tempEdgeMask)');
    const valueDomain = d3.extent(data);
    valueDomain[0] -= this.options.tempDomainPadding;
    valueDomain[1] += this.options.tempDomainPadding;
    const y = d3.scaleLinear()
      .rangeRound([height, 0])
      .domain(valueDomain);
    const x = d3.scaleBand()
      .rangeRound([0, width])
      .padding(0)
      .domain(_.range(data.length));
    const area = d3.area()
      .x((d, i) => x(i))
      .y1((d) => y(d))
      .y0(y(valueDomain[0]));
    g.append('path')
      .datum(data)
      .attr('d', area);
  }
}
