var popupElements = new Array();
var popupDialogs = new Array();
var popupContent = new Array();

/* Drag and drop exercises ------------------------------------------------------------------*/

function checkDragExercise(exerciseId) {
    items = $(".exercise-item[exercise-id='" + exerciseId + "'] .exercise-drop-cell");
    var cancel = false;
    items.each(function (index) {
        if (!$(this).attr("droppable-nr")) {
            cancel = true;
        }
    });
    if (cancel)
    {
        alert("Je hebt nog niet alle antwoorden ingevuld!");
        return;
    }

    var allcorrect = true;
    items.each(function (index) {
        if ($(this).attr("droppable-nr")) {
            if ($(this).attr("droppable-nr") == $(this).attr("nr")) {
                $(this).addClass("correct");
                $(this).removeClass("wrong");
            }
            else {
                $(this).addClass("wrong");
                $(this).removeClass("correct");
                allcorrect = false;
            }
        }
    });

    if (allcorrect)
        $(".exercise-result-mark[exercise-id='" + exerciseId + "']").show();
    else
        $(".exercise-result-mark[exercise-id='" + exerciseId + "']").hide();

}

function checkDragExerciseComplete(exerciseId, showMark) {
    items = $(".exercise-item[exercise-id='" + exerciseId + "'] .exercise-drop-cell");
    var cancel = false;
    items.each(function (index) {
        if (!$(this).attr("droppable-nr")) {
            cancel = true;
        }
    });
    if (cancel) {
        $(".exercise-result-check[exercise-id='" + exerciseId + "']").hide();
        $(".exercise-result-mark[exercise-id='" + exerciseId + "']").hide();
        return;
    }
    else if (!showMark)
        $(".exercise-result-check[exercise-id='" + exerciseId + "']").show();

    var allcorrect = true;
    items.each(function (index) {
        if ($(this).attr("droppable-nr")) {
            if ($(this).attr("droppable-nr") != $(this).attr("nr")) {
                allcorrect = false;
            }
        }
    });

    if (allcorrect && showMark)
        $(".exercise-result-mark[exercise-id='" + exerciseId + "']").show();
    else
        $(".exercise-result-mark[exercise-id='" + exerciseId + "']").hide();
}

/* Entry exercises --------------------------------------------------------------------------*/

function checkEntryExerciseComplete(exerciseId)
{
    var items = $(".exercise-item[exercise-id='" + exerciseId + "'] .entry-item");
    var cancel = false;
    items.each(function (index) {
        if ($(this).val().trim() == "") {
            cancel = true;
        }
    });

    $(".exercise-result-show[exercise-id='" + exerciseId + "']").hide();
    if (cancel) {
        $(".exercise-result-check[exercise-id='" + exerciseId + "']").hide();
    }
    else {
        $(".exercise-result-check[exercise-id='" + exerciseId + "']").show();
    }
}

String.prototype.translate = function (from, to) {
    var sl = this.length,
		tl = to.length,
		xlat = new Array(),
		str = '';

    if (sl < 1 || tl < 1) return this;

    for (i = 0; i < 256; xlat[i] = i, i++);

    for (i = 0; i < tl; i++) {
        xlat[from.charCodeAt(i)] = to.charCodeAt(i);
    }

    for (i = 0; i < sl; i++) {
        str += String.fromCharCode(xlat[this.charCodeAt(i)]);
    }

    return str;
}

function checkEntryExercise(exerciseId, casesensitive, showanwsersbutton)
{
    var items = $(".exercise-item[exercise-id='" + exerciseId + "']").find(".entry-item");
    var allcorrect = true;
    items.each(function (index) {
        var entryCorrect = false;
        var entryItem = $(this);
        var answers = entryItem.attr("answers").split("|");
        answers.pop();
        $.each(answers, function (index, value) {
            var entryVal = entryItem.val().trim();
            if (!casesensitive)
                entryVal = entryVal.toLowerCase();
            var compareVal = value.translate("4250318697qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM", "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890");
            if (!casesensitive)
                compareVal = compareVal.toLowerCase();
            if (entryVal == compareVal)
                entryCorrect = true;
        });
        if (entryCorrect)
        {
            entryItem.addClass("correct");
            entryItem.removeClass("wrong");
        }
        else
        {
            allcorrect = false;
            entryItem.addClass("wrong");
            entryItem.removeClass("correct");
        }
    });

    if (allcorrect) {
        $(".exercise-result-mark[exercise-id='" + exerciseId + "']").show();
        $(".exercise-result-show[exercise-id='" + exerciseId + "']").hide();
    }
    else {
        $(".exercise-result-mark[exercise-id='" + exerciseId + "']").hide();
        if (showanwsersbutton)
            $(".exercise-result-show[exercise-id='" + exerciseId + "']").show();
    }
}

function showEntryExercise(exerciseId) {
    var items = $(".exercise-item[exercise-id='" + exerciseId + "']").find(".entry-item");
    items.each(function (index) {
        var entryItem = $(this);
        var answers = entryItem.attr("answers").split("|");
        var compareVal = answers[0].translate("4250318697qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM", "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890");
        entryItem.val(compareVal);
        entryItem.removeClass("wrong");
        entryItem.removeClass("correct");
    });
    $(".exercise-result-check[exercise-id='" + exerciseId + "']").hide();
}


$(document).ready(function () {

    var TOLX = 20; var TOLY = 10;
    var elm = $('.menu-hierarchy').first();
    elm = $('.menu-item', elm).first();
    SVO_triggerMenuItem(elm);

    /* Drag and drop exercises ------------------------------------------------------------------*/

    $(".exercise-drop-cell").draggable({
        start: function(event, ui) {
            $(this).data("draggable").originalPosition = {
                top: 0,
                left: 0
            };
        }
        ,
        revert: function (event, ui) {
            var showmark = true;
            if (!$(this).hasClass('hintmode-drag') && !$(this).hasClass('hintmode-drop') && !$(this).hasClass('hintmode-revert'))
                showmark = false;
            checkDragExerciseComplete($(this).attr("exercise-id"), showmark);
            return !event;
        }
    });

    $(".drop-item").droppable({
        tolerance: "pointer",
        drop: function (ev, ui) {
            if ($(ui.draggable).hasClass('hintmode-drag') || $(ui.draggable).hasClass('hintmode-drop')) {
                $(ui.draggable).offset($(this).offset());
                $(ui.draggable).attr("droppable-nr", $(this).attr('nr'));
                checkDragExerciseComplete($(ui.draggable).attr("exercise-id"), true);
                if ($(ui.draggable).attr('nr') == $(this).attr('nr')) {
                    $(ui.draggable).addClass("correct");
                    $(ui.draggable).removeClass("wrong");
                }
                else {
                    $(ui.draggable).addClass("wrong");
                    $(ui.draggable).removeClass("correct");
                }
            }
            else if ($(ui.draggable).hasClass('hintmode-revert')) {
                if ($(ui.draggable).attr('nr') != $(this).attr('nr')) {
                    $(ui.draggable).attr("droppable-nr", null);
                    $(ui.draggable).animate({ 'left': $(ui.draggable).data("draggable").originalPosition.left, 'top': $(ui.draggable).data("draggable").originalPosition.top });
                    checkDragExerciseComplete($(ui.draggable).attr("exercise-id"), true);
                    $(ui.draggable).removeClass("wrong");
                    $(ui.draggable).removeClass("correct");
                    $(ui.draggable).removeClass("neutral");
                    $(this).removeClass("wrong");
                    $(this).removeClass("correct");
                    $(this).removeClass("neutral");
                }
                else
                {
                    $(ui.draggable).offset($(this).offset());
                    $(ui.draggable).attr("droppable-nr", $(this).attr('nr'));
                    checkDragExerciseComplete($(ui.draggable).attr("exercise-id"), true);
                }
            }
            else {
                $(ui.draggable).offset($(this).offset());
                $(ui.draggable).attr("droppable-nr", $(this).attr('nr'));
            }
        }
        ,
        over: function (ev, ui)
        {
            if ($(ui.draggable).hasClass('hintmode-drag')) {
                // hintmode-drag means answer hints are displayed while dragging the element over drop targets
                if ($(ui.draggable).attr('nr') == $(this).attr('nr')) {
                    $(this).addClass("correct");
                    $(this).removeClass("wrong");
                }
                else {
                    $(this).addClass("wrong");
                    $(this).removeClass("correct");
                }
            }
            else
            {
                $(this).addClass("neutral");
            }
        }
        ,
        out: function (ev, ui)
        {
            $(ui.draggable).attr("droppable-nr", null);
            $(ui.draggable).removeClass("wrong");
            $(ui.draggable).removeClass("correct");
            $(ui.draggable).removeClass("neutral");
            $(this).removeClass("wrong");
            $(this).removeClass("correct");
            $(this).removeClass("neutral");
        }
    });

    /* Entry exercises --------------------------------------------------------------------------*/

    $(".entry-item").bind('input', function () {
        $(this).removeClass("correct");
        $(this).removeClass("wrong");
        checkEntryExerciseComplete($(this).closest(".exercise-item").attr("exercise-id"));
    });

    /* Movie stuff ------------------------------------------------------------------------------*/

//    var player = $(".movie_jplayer").jPlayer({
//        ready: function () {
//            var src = $(this).attr('src');
//            $(this).jPlayer("setMedia", {
//                //m4v: src,
//                //ogv: "http://www.jplayer.org/video/ogv/Big_Buck_Bunny_Trailer.ogv",
//                webmv: src
//                //poster: "http://www.jplayer.org/video/poster/Big_Buck_Bunny_Trailer_480x270.png"
//            });
//        },
//        swfPath: "javascript/Jplayer.swf",
//        //		supplied: "webmv, ogv, m4v",
//        supplied: "webmv",
//        size: {
//            width: "320px",
//            height: "180px",
//            cssClass: "jp-video-360p"
//        }
//    });
    //$(".jplayer_inspector").jPlayerInspector({jPlayer:player});
    
    $(".item-next").click(function () { nextItem(this) });
    $(".item-feedback").click(function () { showFeedback(this) });
    
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
    $('#' + tabid + ' *[ontab]').each(function(index, elm) {
    	eval($(elm).attr("ontab"));
    });
    //als meerdere pagina's, maak eerste pagina actief
    var page = $('.pages-container .page.selected', '#' + tabid).first();
    if (page.length > 0) {
        var elm = $('.page-navigator .page-navigator-ref', '#' + tabid).first();
        togglePage(elm);
    }
    else {
    	// set readspeaker url
    	if (typeof readspeaker_lang !== 'undefined') {
	    	if ($('#' + tabid).attr('noreadspeaker') == '1') {
	    	    $('.rsbtn_play').hide();
	    	} 
	    	else {
	    		ReadSpeaker.q(function(){if(rspkr.ui.getActivePlayer()){rspkr.ui.getActivePlayer().close()}});
	    		$('.rsbtn_play').attr('href', 'https://app.readspeaker.com/cgi-bin/rsent?customerid=7345&lang=' + readspeaker_lang + '&amp;dict=no_main&readid='+tabid+'&url=' + encodeURIComponent(document.URL));
	    	    $('.rsbtn_play').show();
	    	}
	    }
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
    var scoreHolder = $(elm).parents('.exercise-multi-item').first();
    var totalClicks = scoreHolder.data("total");
    if (totalClicks == null) totalClicks = 0;
    var correctClicks = scoreHolder.data("correct");
    if (correctClicks == null) correctClicks = 0;
    var par = $(elm).parents('.choice-exercise-option');
    var expar = $(par).parents('.exercise-item');
    var waschecked = par.hasClass('checked');
    $('.choice-exercise-option', expar).removeClass('checked'); // remove all checks
    $('.choice-exercise-option .feedback', expar).removeClass('show');
    if ($('.choice-exercise-option .feedback', expar).length > 0)
        $('.item-feedback', expar).addClass('show');
    par.addClass('checked');
    var total_correct = $('*[state="yes"]', expar).length;
    var state = $(par).attr('state');
    if (state == 'yes') {
        $('.choise-exercise-label', expar).removeClass('wrong-answer');
        $(elm).addClass('good-answer');
        if ($('.good-answer', expar).length == total_correct) {
            if (expar.next().length > 0) {
                $('.item-next', expar).addClass('show');
            } else {
                $('.exercise-completed', $(elm).parents('.exercise')).addClass('show');
            }
        } else {
            $('.item-next', expar).removeClass('show');
            $('.exercise-completed', $(elm).parents('.exercise')).removeClass('show');
        }
        if (!waschecked) {
            totalClicks++;
            correctClicks++;
        }
    } else {
        $('.choise-exercise-label', expar).removeClass('good-answer');
        $(elm).addClass('wrong-answer');
        $('.item-next', expar).removeClass('show');
        $('.exercise-completed', $(elm).parents('.exercise')).removeClass('show');
        if (!waschecked) {
            totalClicks++;
        }
    }

    scoreHolder.data("total", totalClicks);
    scoreHolder.data("correct", correctClicks);
    $('.item-score', scoreHolder).text("Score: " + (correctClicks / totalClicks * 100).toFixed(0) + "%");
}

function multipleLabelClick(elm) {
    var scoreHolder = $(elm).parents('.exercise-multi-item').first();
    var totalClicks = scoreHolder.data("total");
    if (totalClicks == null) totalClicks = 0;
    var correctClicks = scoreHolder.data("correct");
    if (correctClicks == null) correctClicks = 0;
    var par = $(elm).parents('.multiple-exercise-option');
    var expar = $(par).parents('.exercise-item');
    $('.multiple-exercise-option .feedback', expar).removeClass('show');
    if ($('.multiple-exercise-option .feedback', expar).length > 0)
        $('.item-feedback', expar).addClass('show');
    var total_correct = $('*[state="yes"]', expar).length;
    var state = $(par).attr('state');
    if (state == 'yes') {
//        $('.multiple-exercise-label', expar).removeClass('wrong-answer');
        if ($(elm).hasClass('good-answer')) {
            $(elm).removeClass('good-answer');
            par.removeClass('checked');
        }
        else {
            $(elm).addClass('good-answer');
            par.addClass('checked');
            totalClicks++;
            correctClicks++;
        }
    } else {
//        $('.multiple-exercise-label', expar).removeClass('good-answer');
        if ($(elm).hasClass('wrong-answer')) {
            $(elm).removeClass('wrong-answer');
            par.removeClass('checked');
        }
        else {
            $(elm).addClass('wrong-answer');
            par.addClass('checked');
            totalClicks++;
        }
        $('.item-next', expar).removeClass('show');
        $('.exercise-completed', $(elm).parents('.exercise')).removeClass('show');
    }

    scoreHolder.data("total", totalClicks);
    scoreHolder.data("correct", correctClicks);
    $('.item-score', scoreHolder).text("Score: " + (correctClicks / totalClicks * 100).toFixed(0) + "%");

    if ($('.good-answer', expar).length == total_correct && $('.wrong-answer', expar).length == 0) {
        if (expar.next().length > 0) {
            $('.item-next', expar).addClass('show');
        } else {
            $('.exercise-completed', $(elm).parents('.exercise')).addClass('show');
        }
    } else {
        $('.item-next', expar).removeClass('show');
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

function showFeedback(elm)
{
    var par = $(elm).parents('.exercise-item');
    $('.choice-exercise-option.checked .feedback', par).addClass('show');
    $('.multiple-exercise-option.checked .feedback', par).addClass('show');
}

function togglePage(elm) {
	console.log("togglePage called " + $(elm).attr('noreadspeaker'));
    var num = $(elm).text();
    var parent = $(elm).parents('.pages-container').first();
    $('.page', parent).removeClass('selected');
    var selectedPage = $('.page[num="' + num + '"]', parent);
    $(selectedPage).addClass('selected');
    $('.page-navigator-ref', parent).removeClass('selected');
    var selectedPageNav = $('.page-navigator-ref[num="' + num + '"]', parent);
    $(selectedPageNav).addClass('selected');
    // set readspeaker url
    var noreadspeaker = $(elm).attr('noreadspeaker') == 'true';
    if (typeof readspeaker_lang !== 'undefined' && !noreadspeaker) {
	    ReadSpeaker.q(function(){if(rspkr.ui.getActivePlayer()){rspkr.ui.getActivePlayer().close()}});
	    $('.rsbtn_play').attr('href', 'https://app.readspeaker.com/cgi-bin/rsent?customerid=7345&amp;lang=' + readspeaker_lang + '&amp;readid='+$(selectedPage).attr('id')+'&amp;url=' + encodeURIComponent(document.URL));
	    $('.rsbtn_play').show();
    }
    else {
	    ReadSpeaker.q(function(){if(rspkr.ui.getActivePlayer()){rspkr.ui.getActivePlayer().close()}});
	    $('.rsbtn_play').hide();
    }
}

function toggleMovie(elm) {
    var parent = $(elm).parents('.movie-wrapper');
    var movie = $('.movie', parent);
    var index = popupElements.indexOf(elm);
    if (index == -1) {
        var player = null;
        var id = $("video", movie).attr('id');
        var attr = $("video", movie).attr('width');
        var width = 500;
        if (typeof attr !== typeof undefined && attr !== false)
        	width = parseInt(attr) + 24; // 24 is padding (2x12)
        movie.toggleClass('visible');

        var dialog = movie.dialog({
            autoOpen: false,
            width: width,
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
var tempvar = "";
function togglePopup(width, restart, elm) {
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
            position: position,
            beforeClose: function (event, ui) {
                // the popup can contain a playing video. We dont want the video (or anything else) to play on when the popup is closed. 
                // Therefore we have to remove the html in the popup, store it and insert it back into the popup when its reopened again.
                if (restart) {
                    content.data('storedhtml', content.html());
                    content.empty();
                }
            }
        });
        popupElements.push(elm);
        popupDialogs.push(dialog);
        popupContent.push(content);
        dialog.dialog('open');
        // load iframes inside the popup
        $(content).find('iframe').each(function (index) {
            $(this).attr("src", $(this).attr("src-orig"));
        });;
    }
    else {
        if (restart)
            popupContent[index].html(popupContent[index].data('storedhtml'));
        popupDialogs[index].dialog('open');
    }
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

function toggleToets(elm, src) {
    var parent = $(elm).parents('.toets-wrapper').first();
    var asm = $('div.toets-content', parent);
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

function toggleSlider(elm) {
    var parent = $(elm).parents('.slider-wrapper').first();
    var content = $('.slider-content', parent).first();
    if ($(content).is(':visible'))
        $(elm).removeClass("open");
    else
        $(elm).addClass("open");
    $(content).slideToggle("slow", function () { $(content).scrollIntoView(); });
}
// Shows the url in an iframe inside a popup
function toggleParentPopup(data) {
	var url = data.split("|")[0];
	var itemid = data.split("|")[1];
	var viewid = data.split("|")[2];
	var position = { my: 'center center', at: 'center top', of: '#content' };
    var content = $('#parent-popup');
    if (content.parents('.popup-content').length > 0) {
        position = { my: 'center top', at: 'center center', of: $(elm) };
    }
    var dialog = content.dialog({
        autoOpen: false,
        width: 785,
        position: position,
        close: function(event,ui) {
        	$(content).find('.content-tab.selected iframe').attr("src", "about:blank");
        	if (viewid == "") { // refresh result frame after closing popup, but only if teacher is viewing, in that case viewid != ""
	        	var src = $('iframe.result-frame').attr('src');
	        	var idx = src.lastIndexOf("&itemid=");
	        	if (idx > -1)
	        		src = src.substr(0, idx);
	        	idx = src.lastIndexOf("?itemid=");
	        	if (idx > -1)
	        		src = src.substr(0, idx);
	        	if (src.indexOf("?") > -1)
	        		src += "&";
	        	else
	        		src += "?";
	        	src += "itemid=" + itemid;
	        	$('iframe.result-frame').attr('src', src);
	        }
        }
    });
    dialog.dialog('open');
    // load iframes inside the popup
    $(content).find('iframe').each(function (index) {
        $(this).attr("src", url);
    });
}
// Sends a message to the parent of the iframe to show the url in a popup (popups in iframes dont work well)
function sendToggleParentPopup(url) {
	$.postMessage(url, "*");
}
function getURLParameter(sParam)
{
    var sPageURL = window.location.search.substring(1);
    var sURLVariables = sPageURL.split('&');
    for (var i = 0; i < sURLVariables.length; i++) 
    {
        var sParameterName = sURLVariables[i].split('=');
        if (sParameterName[0] == sParam) 
        {
            return sParameterName[1];
        }
    }
}