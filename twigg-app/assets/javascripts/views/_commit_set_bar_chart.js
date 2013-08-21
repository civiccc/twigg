Twigg.Views.CommitSetBarChart = Backbone.View.extend({
  initialize: function() {
    this.loadCommitsPerDay();
  },

  render: function() {
    var height = 200,
        width = this.$el.width(),
        padding = 45,
        barSpacing = 1,
        barWidth = (width - padding) / this.data.length - barSpacing,
        x = d3.scale.linear()
          .domain([0, this.data.length])
          .range([0, width]),
        y = d3.scale.linear()
          .domain([0, d3.max(this.data, function(d) { return d.count; })])
          .range([height, 0]),
        xTimeScale = d3.time.scale()
          .domain([
            new Date(this.data[0].date),
            d3.time.day.offset(new Date(this.data[this.data.length - 1].date), 1)
          ])
          .range([0, width]),
        xAxis = d3.svg.axis()
          .scale(xTimeScale)
          .orient('bottom')
          .ticks(d3.time.days, 1)
          .tickFormat(d3.time.format('%Y-%m-%d')),
        yAxis = d3.svg.axis()
          .scale(y)
          .orient('left')
          .tickFormat(d3.format(',d')),
        svg = d3.select(this.el).append('svg')
          .attr('height', height + padding)
          .attr('width', width);

    // bars
    svg.selectAll('rect').data(this.data)
      .enter()
        .append('rect')
        .attr({
          'class': 'bar',
          'x': function(d, i) { return x(i) + padding; },
          'y': function(d) { return y(d.count); },
          'width': barWidth,
          'height': function(d) { return height - y(d.count); },
          'title': function(d) { return d.count + ' (' + d.date + ')'; },
          'data-toggle': 'tooltip'
        });

    $('[data-toggle=tooltip]').tooltip({ container: 'body' });

    // show count inside bars if wide/high enough
    if (barWidth > 20) {
      svg.selectAll('text').data(this.data)
        .enter()
          .append('text')
          .attr('x', function(d, i) { return x(i) + barWidth + padding; })
          .attr('y', function(d, i) { return y(d.count); })
          .attr('dx', -barWidth / 2)
          .attr('dy', '1.2em')
          .attr('text-anchor', 'middle')
          .attr('class', 'value')
          .text(function(d) { return height - y(d.count) > 15 ? d.count : ''; });
    }

    // x-axis
    svg.append('g')
      .attr('class', 'xaxis axis')
      .attr('transform', 'translate(' + padding + ', ' + height + ')')
      .call(xAxis);

    // y-axis
    svg.append('g')
      .attr('class', 'yaxis axis')
      .attr('transform', 'translate(' + padding + ', 0)')
      .call(yAxis)
      .append('text')
        .attr('transform', 'rotate(-90)')
        .attr('y', 6)
        .attr('dy', '.71em')
        .style('text-anchor', 'end')
        .text('Commits');

    // date labels
    svg.selectAll('.xaxis text')
      .attr('transform', function(d) {
        var h = this.getBBox().height;
      return 'translate(' + h * -1 + ', ' + h + ') rotate(-30)';
    });

    return this;
  },

  loadCommitsPerDay: function() {
    d3.json(window.location.href)
      .on('error', this.$el.displayAlert)
      .on('load', function(data) {
        this.$el.empty();
        this.data = data;
        this.render();
      }.bind(this)).get();
  }
});
