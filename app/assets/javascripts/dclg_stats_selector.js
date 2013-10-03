//= require modal

$(function() {
  $('#reveal-non-imported-data').click(function(e) {
    e.preventDefault();
    $('#non-imported-data').toggle();
  });

  $('.btn-add-data').click(function(e) {
    e.preventDefault();
  });
});