//= require_tree ./views
//= require_self

$(document).initializeEach('[data-view]', function() {
  var $el      = $(this),
      viewName = $el.data('view'),
      data     = _.extend({ el: this }, $el.data());

  new Twigg.Views[viewName](_.omit(data, 'view'));
});
