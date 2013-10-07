function login(form) {
    $('#message').html('');
    var name = form.username.value;
    var pass = form.password.value;
    $.post('login', {
                name: name,
                password: pass
            },
            function(data,textstatus) {
                var result = $('login', data).attr('result');
                if(result=='true'){
                    
                } else {
                    $('#message').html($('message', data).text());
                }
            }
    ).fail(function(){alert('Fout: kan geen verbinding maken met de server.');});
    
}

function register(form) {
    $('#message').html('');
    var name = form.username.value;
    var pass = form.password.value;
    $.post('register', {
                name: name,
                password: pass
            },
            function(data,textstatus) {
                var result = $('register', data).attr('result');
                if(result=='true'){
                    
                } else {
                    $('#message').html($('message', data).text());
                }
            }
    ).fail(function(){alert('Fout: kan geen verbinding maken met de server.');});
    
}

