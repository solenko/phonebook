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

})

