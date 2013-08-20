Twigg.Russia = (function() {
  var showNovelStats = function() {
    var diameter = Math.min($('.bubble-chart').width(), window.innerHeight * 1.2),
        format = d3.format(',d'),
        color = d3.scale.category20c(),
        bubble = d3.layout.pack()
          .size([diameter, diameter])
          .sort(function(a, b) { return a.russianness - b.russianness; } )
          .value(function(d) { return d.russianness; })
          .padding(1.5),
        svg = d3.select('.bubble-chart').append('svg')
          .attr('height', diameter)
          .attr('width', diameter);

    d3.json('#{russian_novels_path(days: @days)}')
      .on('error', function() { $('.bubble-chart').displayAlert(); })
      .on('load', function(data) {
        $('.bubble-chart .progress').remove();
        var node = svg.selectAll('.node')
          .data(bubble.nodes(data).filter(function(d) { return !d.children; }))
          .enter().append('g')
            .attr('class', 'node')
            .attr('transform', function(d) { return "translate(" + d.x + ',' + d.y + ')'; });

        node.append('title')
          .text(function(d) {
            return 'Author: ' + d.author + ' (' + d.team + ')\n' +
                   'Russianness: ' + format(d.russianness) + '\n' +
                   'Flesch Reading Ease: ' + d3.round(d.flesch_reading_ease, 2);
          });

        node.append('circle')
          .attr('r', function(d) { return d.r; })
          .style('fill', function(d) { return color(d.team) });

        node.append('text')
          .attr('dy', '.3em')
          .style('text-anchor', 'middle')
          .text(function(d) { return d.author.substring(0, d.r / 4); });

        $('.bubble-chart svg').on('click', 'g', function(event) {
          window.location = '#{authors_path}/'+
            $(event.currentTarget).find('text').text().replace(/ /, '.');
        });
      }).get();
  };

  return {
    showNovelStats: showNovelStats
  };
})();