// jQuery functions

// Displays an alert inside the currently selected element, by emptying it and
// inserting a Bootstrap alert with the specified `text`.
//
// If `text` is omitted, a reasonable default it used, based on the motivatiing
// use case of providing feedback for failed Ajax requests.
//
// So-named in order to avoid a clash with Boostrap's `alert()` method.
$.fn.displayAlert = function(text) {
  if (!text) {
    text = 'There was a problem retrieving the data. ' +
      '<a class="alert-link" href="' + window.location.href + '">Reload</a>.';
  }

  return this
    .empty()
    .append('<div class="alert alert-danger">' + text + '</div>');
};
