// View for /gerrit/tags.
//
// Manages a set of TagsWordCloud subviews, one per word cloud.
Twigg.Views.Tags = Backbone.View.extend({
  initialize: function() {
    this.$globalUsed = $('#global-used');
    this.width = this.$globalUsed.width();
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
    // first render global stats
    new Twigg.Views.TagsWordCloud({
      el:    this.$globalUsed[0],
      data:  this.data.global,
      width: this.width
    });

    // then render per-author stats
    var authors = JSON.parse(_.unescape(this.$el.data('authors')));
    _.each(authors, function(author, idx, list) {
      var id = this.nameToId(author);

      // tags used
      new Twigg.Views.TagsWordCloud({
        el:    this.$('#' + id + '-used')[0],
        data:  this.data.from[author],
        width: this.width
      });

      // tags received
      new Twigg.Views.TagsWordCloud({
        el:    this.$('#' + id + '-received')[0],
        data:  this.data.to[author],
        width: this.width
      });
    }, this);

    return this;
  },

  // Duplicative of `#name_to_id` Ruby method in Twigg::App::Server.
  nameToId: function(name) {
    return name.replace(/[ .@]/, '-').toLowerCase();
  }
});
