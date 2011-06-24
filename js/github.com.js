var hideRails = function(){
  $('.alert .body .title a:contains("rails/rails")')
    .parent('.title').parent('.body').parent('.alert').hide();
}
$('ul.tabs').append('<li><a href="#" id="hiderails">Hide Rails</a></li>');
$('#hiderails').click(hideRails);