// View for /gerrit/tags.
//
// Manages a set of TagsWordCloud subviews, one per word cloud.
Twigg.Views.Tags = Backbone.View.extend({
  initialize: function() {
    this.$globalUsed = $('#global-used');
    this.fetch();
  },

  fetch: function() {
    $.getJSON(window.location.href)
      .fail(function() { this.$globalUsed.displayAlert(); }.bind(this))
      .done(function(data) {
        this.$globalUsed.empty();
        this.data = data;
        this.render();
      }.bind(this));
  },

  render: function() {
    var subview = new Twigg.Views.TagsWordCloud({
      el:   this.$globalUsed[0],
      data: this.data
    });

    subview.render();
  }
});
