Twigg = {};
Twigg.Profile = (function() {
  var loadCommitsPerDay = function(selector) {
    d3.json(window.location.href)
      .on('error', function() { $('.bar-chart').displayAlert(); })
      .on('load', function(data) {
          $(selector).empty();

          var height = 200,
              width = $('.bar-chart').width(),
              padding = 45,
              barSpacing = 1,
              barWidth = (width - padding) / data.length - barSpacing,
              x = d3.scale.linear()
                .domain([0, data.length])
                .range([0, width]),
              y = d3.scale.linear()
                .domain([0, d3.max(data, function(d) { return d.count; })])
                .range([height, 0]),
              xTimeScale = d3.time.scale()
                .domain([
                  new Date(data[0].date),
                  d3.time.day.offset(new Date(data[data.length - 1].date), 1)
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
              svg = d3.select(selector).append('svg')
                .attr('height', height + padding)
                .attr('width', width);

          // bars
          svg.selectAll('rect').data(data)
            .enter()
              .append('rect')
              .attr({
                'class': 'bar',
                'x': function(d, i) { return x(i) + padding },
                'y': function(d) { return y(d.count) },
                'width': barWidth,
                'height': function(d) { return height - y(d.count); },
                'title': function(d) { return d.count + ' (' + d.date + ')'; },
                'data-toggle': 'tooltip'
              });

          $('.bar-chart [data-toggle=tooltip]').tooltip({ container: 'body' });

          // show count inside bars if wide/high enough
          if (barWidth > 20) {
            svg.selectAll('text').data(data)
              .enter()
                .append('text')
                .attr('x', function(d, i) { return x(i) + barWidth + padding; })
                .attr('y', function(d, i) { return y(d.count); })
                .attr('dx', -barWidth / 2)
                .attr('dy', '1.2em')
                .attr('text-anchor', 'middle')
                .attr('class', 'value')
                .text(function(d) { return height - y(d.count) > 15 ? d.count : '' });
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
        }).get();
  };

  return {
    loadCommitsPerDay: loadCommitsPerDay
  };
})();
