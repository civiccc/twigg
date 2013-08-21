// View for /gerrit/tags.
//
// Manages a set of TagsWordCloud subviews, one per word cloud.
Twigg.Views.Tags = Backbone.View.extend({
  initialize: function() {
    $.getJSON(window.location.href)
      .done(function(data) {
        this.data = data;
        this.render();
      }.bind(this));
  },

  render: function() {
    var subview = new Twigg.Views.TagsWordCloud({
      el:   $('#global-used')[0],
      data: this.data
    });

    subview.render();
  }
});
