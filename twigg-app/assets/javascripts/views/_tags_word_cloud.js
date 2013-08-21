Twigg.Views.TagsWordCloud = Backbone.View.extend({
  render: function() {
    var entries = d3.map(this.options.data.global).entries(),
        fill = d3.scale.category20(),
        height = window.innerHeight * .8,
        domain = d3.extent(entries, function(d) { return d.value; }),
        scale = d3.scale.log().range([10, height * .5]).domain(domain),
        width = this.$el.width(),
        words = entries.map(function(d) { return { text: d.key, size: d.value }; });

    d3.layout.cloud()
      .size([width, height])
      .words(words)
      .padding(5)
      .rotate(function() { return ~~(Math.random() * 2) * 90; })
      .font('Impact')
      .fontSize(function(d) { return scale(d.size); })
      .on('end', draw.bind(this))
      .start();

    function draw(words) {
      d3.select(this.el)
        .append('svg')
          .attr('width', width)
          .attr('height', height)
        .append('g')
          .attr('transform', 'translate(' + (width / 2) + ',' + (height / 2) + ')')
        .selectAll('text')
          .data(words)
        .enter().append('text')
          .style('font-size', function(d) { return d.size + 'px'; })
          .style('font-family', 'Impact')
          .style('fill', function(d, i) { return fill(i); })
          .attr('text-anchor', 'middle')
          .attr('transform', function(d) {
            return 'translate(' + [d.x, d.y] + ') rotate(' + d.rotate + ')';
          })
          .text(function(d) { return d.text; });
      }
    }
});
