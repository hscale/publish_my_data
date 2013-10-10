//= require modal

$(function() {
  $('#reveal-non-imported-data').click(function(e) {
    e.preventDefault();
    $('#non-imported-data').toggle();
  });

  $('.btn-add-data').click(function(e) {
    e.preventDefault();
  });

  // $('#stats-selector th, #stats-selector td').hover(function() {
  //   $(this).addClass('highlight');
  //   console.log($(this));
  // },
  // function() {
  //   $(this).removeClass('highlight');
  // });
  $('th.fragment-actions').hover(function() {
    $(this).find('.btn').show();
  },
  function() {
    $(this).find('.btn').hide();
  });
});