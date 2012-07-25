// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require bootstrap
//= require rest_in_place
//= require jquery_ujs
//= require_tree .


$(function() {
    var scope = $('#main.c-phones');
    $('#import_form_wrapper', scope).hide();
    $('a.import', scope).click(function(e){
        e.preventDefault();
        $('#import_form_wrapper', scope).slideToggle();
    });

    $('a.new', scope).click(function(e) {
        e.preventDefault();
        $('#phone_form_wrapper').slideDown();
    });

    $('a.destroy', scope).bind('ajax:error', function(e, xhr, error) {
        if (xhr.status === 200 && error == "parsererror") {
            $(this).parents('tr').remove();
        }
    });

    $('#phone_form a.cancel', scope).click(function(e) {
        e.preventDefault();
        $('#phone_form_wrapper').slideUp();
    });

    $('#phone_form').bind('ajax:error', function(e, xhr, error) {
        if (xhr.status === 200 && error == "parsererror") {
            $('#phones_list tbody').prepend(xhr.responseText);
            $('#phone_form_wrapper').slideUp();
        }else {
            $('#phone_form_wrapper').html(xhr.responseText);
        }
    });

    $(document).ajaxComplete(function(e, xhr) {
        var renderMessage = function(type, message) {
          var html = '<div class="alert alert-' + type + '">' +
                       '<a class="close" data-dismiss="alert"> × </a>' +
                       '<div>' + message + '</div>'
                     '</div>';
          $('#messages').html(html);
        };
        var message;
        if (message = xhr.getResponseHeader('X-Message-Notice')) {
            renderMessage('success', message);
        }
        if (message = xhr.getResponseHeader('X-Message-Alert')) {
            renderMessage('error', message);
        }
    });

})

