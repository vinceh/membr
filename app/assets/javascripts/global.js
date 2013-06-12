$(document).on('click', '.settings', (function() {
  $('.membership-edit').appendTo($(this).parents('.membership'));
  $('.membership-edit').fadeIn();
}));

$(document).on('click', '.close-edit-form', (function() {
  $('.membership-edit').fadeOut();
}));

$(document).ready(function() {
  $('.nav-item').click(function() {
    var $this = $(this);

    if ( !$this.hasClass('active') ) {
      var items = $('.nav-panel .nav-item');
      var currentPanel = $('.'+$('.nav-panel .active').attr('data-panel'));
      var newPanel = $('.'+$this.attr('data-panel'));

      items.removeClass('active');
      $this.addClass('active');

      currentPanel.fadeOut( function() {
        newPanel.fadeIn();
      });
    }
  });
});