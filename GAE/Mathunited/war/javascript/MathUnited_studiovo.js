var popupElements = new Array();
var popupDialogs = new Array();

$(document).ready(function() {
    var TOLX = 20; var TOLY = 10;
    var elm = $('.menu-hierarchy').first();
    elm = $('.menu-item', elm).first();
    SVO_triggerMenuItem(elm);
    $(".exercise-drop-cell").draggable({
        start: function() {
            var org_x = $(this).attr('org_x');
            if (!org_x) {
                var pos = $(this).offset();
                $(this).attr('org_x', pos.left);
                $(this).attr('org_y', pos.top);
            }
        },
        stop: function() {
            var pos = $(this).offset();
            var nr = $(this).attr('nr');
            var parent = $(this).parents('.exercise-item-drop').first();
            var pair = $('.drop-item[nr=' + nr + ']', parent);
            var pos2 = pair.offset();
            if (Math.abs(pos.left - pos2.left) < TOLX && Math.abs(pos.top - pos2.top) < TOLY) {
                $(this).offset(pos2);
            } else {
                var posOrg = {
                    left: parseFloat($(this).attr('org_x')),
                    top: parseFloat($(this).attr('org_y'))
                }
                $(this).offset(posOrg);
            }
        }

    });

    var player = $(".movie_jplayer").jPlayer({
        ready: function () {
            var src = $(this).attr('src');
            $(this).jPlayer("setMedia", {
                //m4v: src,
                //ogv: "http://www.jplayer.org/video/ogv/Big_Buck_Bunny_Trailer.ogv",
                webmv: src
                //poster: "http://www.jplayer.org/video/poster/Big_Buck_Bunny_Trailer_480x270.png"
            });
        },
        swfPath: "javascript/Jplayer.swf",
        //		supplied: "webmv, ogv, m4v",
        supplied: "webmv",
        size: {
            width: "320px",
            height: "180px",
            cssClass: "jp-video-360p"
        }
    });
    //$(".jplayer_inspector").jPlayerInspector({jPlayer:player});

});

function setTab(tabid) {
    var mi = $('div.submenu-item[tabid=' + tabid + ']')
    if (mi.length > 0) {
        $('.submenu-item').removeClass('selected');
        $('.menu-item').removeClass('selected');
        mi.addClass('selected');
        var menuParent = mi.prevAll('.menu-item').first();
        menuParent.addClass('selected');
        //maak kruimelpad
        var str = menuParent.text() + ' - ' + mi.text();
        $('#kruimelpad').html(str);
    }
    $('.content-tab').removeClass('selected');
    $('#' + tabid).addClass('selected');
    //als meerdere pagina's, maak eerste pagina actief
    var page = $('.pages-container .page.selected', '#' + tabid).first();
    if (page.length > 0) {
        var elm = $('.page-navigator .page-navigator-ref', page).first();
        togglePage(elm);
    }

}

function SVO_triggerSubMenuItem(elm) {
    var tabid = $(elm).attr('tabid');
    setTab(tabid);
}
function SVO_triggerMenuItem(elm) {
    var par = $(elm).parents('.menu-hierarchy');
    $('.submenu-item').removeClass('show');
    $('.submenu-item', par).addClass('show');
    var tabid = $('.submenu-item', par).first().attr('tabid');
    setTab(tabid);
}
function choiceLabelClick(elm) {
    var par = $(elm).parents('.choice-exercise-option');
    var expar = $(par).parents('.exercise-item');
    var total_correct = $('*[state="yes"]', expar).length;
    var state = $(par).attr('state');
    if (state == 'yes') {
        $('.choise-exercise-label', expar).removeClass('wrong-answer');
        $(elm).addClass('good-answer');
        if ($('.good-answer', expar).length == total_correct) {
            if (expar.next().length > 0) {
                $('.item-completed', expar).addClass('show');
            } else {
                $('.exercise-completed', $(elm).parents('.exercise')).addClass('show');
            }
        } else {
            $('.item-completed', expar).removeClass('show');
            $('.exercise-completed', $(elm).parents('.exercise')).removeClass('show');
        }
    } else {
        $('.choise-exercise-label', expar).removeClass('good-answer');
        $(elm).addClass('wrong-answer');
        $('.item-completed', expar).removeClass('show');
        $('.exercise-completed', $(elm).parents('.exercise')).removeClass('show');
    }
}
function nextItem(elm) {
    var par = $(elm).parents('.exercise-item');
    var nxt = par.next();
    if (nxt.length > 0) {
        par.removeClass('selected');
        nxt.addClass('selected');
    }
}
function togglePage(elm) {
    var num = $(elm).text();
    var parent = $(elm).parents('.pages-container').first();
    $('.page', parent).removeClass('selected');
    $('.page[num="' + num + '"]', parent).addClass('selected');
}

function toggleMovie(elm) {
    var parent = $(elm).parents('.movie-wrapper');
    var movie = $('.movie', parent);
    var index = popupElements.indexOf(elm);
    if (index == -1) {
        var player = null;
        var id = $("video", movie).attr('id');
        movie.toggleClass('visible');

        var dialog = movie.dialog({
            autoOpen: false,
            width: 500,
            beforeClose: function (event, ui) {
                $('#' + id)[0].pause();
            }
        });
        popupElements.push(elm);
        popupDialogs.push(dialog);
        dialog.dialog('open');
    }
    else
        popupDialogs[index].dialog('open');
}
function togglePopup(width, elm) {
    var parent = $(elm).parents('.popup-wrapper').first();
    var content = $('.popup-content', parent).first();
    var index = popupElements.indexOf(elm);
    if (index == -1) {
        //if this is a nested popup, position relative to parent popup. 
        var position = { my: 'center center', at: 'center top', of: '#content' };
        if (content.parents('.popup-content').length > 0) {
            position = { my: 'center top', at: 'center center', of: $(elm) };
        }

        var dialog = content.dialog({
            autoOpen: false,
            width: parseFloat(width),
            position: position
        });
        popupElements.push(elm);
        popupDialogs.push(dialog);
        dialog.dialog('open');
    }
    else
        popupDialogs[index].dialog('open');
}
function toggleAssessment(elm, src) {
    var parent = $(elm).parents('.assessment-wrapper').first();
    var asm = $('div.assessment-content', parent);
    asm.css('width', parent.attr('popup_width') + 'px');
    var index = popupElements.indexOf(elm);
    if (index == -1) {
        var dialog = asm.dialog({
            autoOpen: false,
            width: parseFloat(parent.attr('popup_width')) + 25
        });
        popupElements.push(elm);
        popupDialogs.push(dialog);
        var frame = $('iframe', asm);
        frame.attr('src', src);
        dialog.dialog('open');
    }
    else
        popupDialogs[index].dialog('open');
}
