URLlogging = '/Publisher/logs/log_{#REPOID}.txt';
URLClearlogging = '/Publisher/php/ClearLogging.php?repo={#REPOID}';
$(document).ready(function(){
    isBusyPublishing = false;
    window.onbeforeunload = confirmExit;
    $("#dialog").dialog({  //create dialog, but keep it closed
        autoOpen: false,
        height: 200,
        width: 380,
        modal: true
    });
    M4A_getLoginState();
    refreshLog(true);
    var tab = m4a_gup('tab');
    if(tab) setTab(tab);
    var thread = m4a_gup('thread');
    if(thread) wm.thread= thread;
    $('iframe').each(function() {
       var src = $(this).attr('link');
       if(src) {
           src = src.replace('{THREAD_ID}',wm.thread);
           $(this).attr('src',src);
       }
    });
});

function m4a_gup( name )
{
  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var href = window.location.href.replace('%20',' ');
  var regexS = "[\\?&]"+name+"=([^&#]*)";
  var regex = new RegExp( regexS );
  var results = regex.exec( href );
  if( results == null )
    return "";
  else
    return results[1];
}

function confirmExit()   {
    if(isBusyPublishing){
        return "Als u het scherm sluit onderbreekt u de publicatie. Wilt u het scherm toch sluiten?";
    }
}

function setTab(id, elm) {
    if($('#li-'+id).hasClass('inactive')) return;
    $('.ui-tab.selected').removeClass('selected');
    $('#menu .selected').removeClass('selected');
    $('#li-'+id).addClass('selected');
    $('#'+id).addClass('selected');
}

function refreshLog(doRepeat) {
    var url = URLlogging.replace('{#REPOID}',wm.repo);
    $.get(url, function success(data){
        var elem = $('#log-contents');
        elem.html(data);
        elem[0].scrollTop = elem[0].scrollTop+.001; //force rendering
    });
    //if(doRepeat)
    //   setTimeout('refreshLog(true)', 1000);
}
function clearLog() {
    var url = URLClearlogging.replace('{#REPOID}',wm.repo);
    $.get(url, function success(data){
        refreshLog(false);
    });
}
function chooseThread(name,elm) {
//    var parent = $(elm).parents('.ui-tab').first();
    var parent = $('.ui-tab.selected');
    var frame = $('iframe',parent).first();

    frame[0].src = name;
    
    //var elm = document.getElementById('wiskundemenu-iframe');
    //elm.src = name;
}
function initUI() {
    var elm = $('#preview-leerlijn-chooser');
    for(var ii=0; ii<wm.threads.length; ii++) {
        elm.append('<div class="choose-leerlijn">'+wm.threads[ii].title+'</div>');
    }
}
function M4A_showLoginDialog() {
    $("#dialog").dialog('open');
}
function M4A_getLoginState(callback) {
    $.get('/MathUnited/loginstate', {},
            function(data,textstatus) {
                var result = $('state', data).attr('result');
                if(result=='true'){
                    if($('state', data).attr('logged-in')=='true'){
                        var name = $('state', data).attr('name');
                        $('#info-username').html('Ingelogd als '+name);
                        $('#info-not-logged-in').removeClass('visible');
                        $('#info-logged-in').addClass('visible');
                        //set all valid options for the repository
                        var opts = $('#repo-set option'); //first remove all current options
                        for(var ii = 0; ii<opts.length; ii++) {
                            $(opts[ii]).remove();
                        }
                        $('repo',data).each(function() {
                            var nstr = $(this).attr('name');
                            $('#repo-set').append('<option value="'+nstr+'">'+nstr+'</option>');
                        });
                        var repo = $('state',data).attr('repo');
                        $('#repo-set option[value='+repo+']').each(function(){
                            $('#repo-set')[0].value=repo;
                        });
                        if(callback) callback();
                        M4A_selectRepo()
                    } else {
                        $('#info-not-logged-in').addClass('visible');
                        $('#info-logged-in').removeClass('visible');
                        if(wm.repo==='malmberg') $('ul#menu li').addClass('inactive');
                    }
                } else {
                    if(wm.repo==='malmberg') $('ul#menu li').addClass('inactive');
                }
            }
    ).fail(function(){ if(wm.repo==='malmberg') $('ul#menu li').addClass('inactive');});
}
function M4A_logout() {
   $.get('/MathUnited/logout', {},
            function(data,textstatus) {
                var result = $('logout', data).attr('result');
                if(result==='true'){
                    $('#info-not-logged-in').addClass('visible');
                    $('#info-logged-in').removeClass('visible');
                    $('#li-tab-edit').addClass('inactive');
                } else {
                    alert($('message', data).text());
                }
                M4A_getLoginState();
            }
    ).fail(function(){alert('Fout: kan geen verbinding maken met de server.');});
}
function M4A_login(form) {
    $('#login-message').html('');
    var name = form.username.value;
    var pass = form.password.value;
    $.post('/MathUnited/login', {
                name: name,
                password: pass
            },
            function(data,textstatus) {
                var result = $('login', data).attr('result');
                if(result=='true'){
                   $('#info-username').html('Ingelogd als '+name);
                   $("#dialog").dialog('close');
                   $('#info-not-logged-in').removeClass('visible');
                   $('#info-logged-in').addClass('visible');
                   //get available repos
                   M4A_getLoginState(function() {
                        var defaultRepo = $('repo',data).text();
                        if(defaultRepo) {
                            $('#repo-set')[0].value=defaultRepo;
                        }                       
                   }); 
                } else {
                    $('#login-message').html($('message', data).text());
                }
            }
    ).fail(function(){alert('Fout: kan geen verbinding maken met de server.');});
    
}
function M4A_forgotPassword(form) {
    $('#login-message').html('');
    var name = form.username.value;
    $.post('/MathUnited/forgotpassword', {
                name: name
            },
            function(data,textstatus) {
                $('#login-message').html($('message', data).text());
            }
    ).fail(function(){alert('Fout: kan geen verbinding maken met de server.');});
    
}
function M4A_register(form) {
    $('#login-message').html('');
    var name = form.username.value;
    var pass = form.password.value;
    $.post('/MathUnited/register', {
                name: name,
                password: pass
            },
            function(data,textstatus) {
                var result = $('register', data).attr('result');
                if(result=='true'){
                    
                } else {
                    $('#login-message').html($('message', data).text());
                }
            }
    ).fail(function(){alert('Fout: kan geen verbinding maken met de server.');});
}

function M4A_selectRepo() {
    var repoStr = $('#repo-set')[0].value;
    $('ul#menu li').removeClass('inactive');
    //$('#li-tab-edit').removeClass('inactive');
    /*
    if(repoStr=='m4a') {
        //repoStr = 'concept';
        $('#li-tab-edit').addClass('inactive');
        if($('#li-tab-edit').hasClass('selected')) setTab('tab-home');
    } else {
        $('#li-tab-edit').removeClass('inactive');
    }
    */
    $.get('/MathUnited/setrepo', {repo: repoStr}, function(data){});
}

