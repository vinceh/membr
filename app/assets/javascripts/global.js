$(document).on('click', '.settings', (function() {
  $('.membership-edit').appendTo($(this).parents('.membership'));
  $('.membership-edit').fadeIn();
}));

$(document).on('click', '.close-edit-form', (function() {
  $('.membership-edit').fadeOut();
}));

$(document).ready(function() {
  $("#members").tablesorter({
    headers: { 3: { sorter: false} }
  });
});