$(document).on('ready page:load', function() {
  $('a.load-chart').click(function(e) {
    e.stopPropagation();  // prevent Rails UJS click event
    e.preventDefault();

    ActiveAdmin.modal_dialog("Send email to: ", {emails: 'text'}, function(inputs) {alert (inputs.emails)})
  })
})