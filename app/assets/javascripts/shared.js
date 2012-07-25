$(document).ajaxComplete(function(e, xhr) {
    var renderMessage = function(type, message) {
        var html = '<div class="alert alert-' + type + '">' +
            '<a class="close" data-dismiss="alert"> × </a>' +
            '<div>' + message + '</div>'
        '</div>';
        $('#messages').append(html);
    };
    var message;
    if (message = xhr.getResponseHeader('X-Message-Notice')) {
        renderMessage('success', message);
    }
    if (message = xhr.getResponseHeader('X-Message-Alert')) {
        renderMessage('error', message);
    }
});