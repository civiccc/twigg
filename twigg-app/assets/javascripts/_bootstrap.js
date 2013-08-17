$(document).initializeEach('[data-toggle=tooltip]', function() {
  $(this).tooltip();
});

$(document).initializeEach('[data-toggle=popover]', function() {
  $(this).popover({ html: true });
});
