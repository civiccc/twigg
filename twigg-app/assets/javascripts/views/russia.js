Twigg.Views.Russia = Backbone.View.extend({
  events: {
    'click svg g': 'handleAuthorClick'
  },

  initialize: function() {
    this.showNovelStats();
  },

  render: function() {
    var format = d3.format(',d'),
        color = d3.scale.category20c(),
        diameter = Math.min(this.$el.width(), window.innerHeight * 1.2),
        bubble = d3.layout.pack()
          .size([diameter, diameter])
          .sort(function(a, b) { return a.russianness - b.russianness; } )
          .value(function(d) { return d.russianness; })
          .padding(1.5),
        svg = d3.select(this.el).append('svg')
          .attr('height', diameter)
          .attr('width', diameter),
        node = svg.selectAll('.node')
          .data(bubble.nodes(this.data).filter(function(d) { return !d.children; }))
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
      .style('fill', function(d) { return color(d.team); });

    node.append('text')
      .attr('dy', '.3em')
      .style('text-anchor', 'middle')
      .text(function(d) { return d.author.substring(0, d.r / 4); });
  },

  showNovelStats: function() {
    d3.json(this.options.url)
      .on('error', this.$el.displayAlert)
      .on('load', function(data) {
        this.$('.progress').remove();
        this.data = data;
        this.render();
      }.bind(this)).get();
  },

  handleAuthorClick: function(event) {
    window.location = this.options.authorsPath + '/' +
      $(event.currentTarget).find('text').text().replace(/ /, '.');
  }
});
