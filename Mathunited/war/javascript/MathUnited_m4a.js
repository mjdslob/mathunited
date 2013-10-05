$(document).ready(function() {
    $('.exercise-heading').click(function() {
       var parent = $(this).parents('.exercise-with-heading');
       parent.toggleClass('open');
    });

    $(".menuDiv").jScroll({top:70});
    //disable 'verder' or 'terug' if not applicable
    var cur = $('#selected-menu-item');
    var prev = cur.parent().prev();
    var next = cur.parent().next();
    if(prev.length==0) {
        $('#terug-button').addClass('hidden');
    } else {
        $('#terug-button a').html($('a',prev).html());
    }
    if(next.length==0 || next.attr('item')=='answers') {
        $('#verder-button').addClass('hidden');
    } else {
        $('#verder-button a').html($('a',next).html());
    }
/*    
    $('.textref').each(function(index, elm){
        elm = $(elm);
        var item = elm.attr('item');
        var ref = $('.crossref-item[item="'+item+'.xml"]',$('#info-hidden')).first();
        var num = ref.attr('num');
        if(num){
            elm.html(elm.html()+' '+num);
            if(elm.attr('href')) {
                elm.attr('href', elm.attr('href')+'&num='+num);
            }
        }
    });
*/    
});

function toggleMovie(elm) {
    var parent = $(elm).parents('.movie-wrapper');
    var movie = $('.movie',parent);
    movie.toggleClass('visible');
//    movie.dialog("open");
}

function MU_sequenceNext(_this) {
    var parent = _this.parentNode;
    while(parent!=null && parent.className!='sequence-widget') parent=parent.parentNode;
    if (parent) {
        var visItem = $('.visible', parent);
        var nextItem = visItem.next();
        visItem.removeClass('visible');
        nextItem.addClass('visible');
        if(nextItem.next('.sequence-item').length==0) {
            $(_this).css('display','none');
        }
        $('.sequence-widget-prev',parent).css('display','block');
    }
}
function MU_sequencePrev(_this) {
    var parent = _this.parentNode;
    while(parent!=null && parent.className!='sequence-widget') parent=parent.parentNode;
    if (parent) {
        var visItem = $('.visible', parent);
        var prevItem = visItem.prev();
        visItem.removeClass('visible');
        prevItem.addClass('visible');
        if(prevItem.prev('.sequence-item').length==0) {
            $(_this).css('display','none');
        }
        $('.sequence-widget-next',parent).css('display','block');
    }
}

function MU_terug() {
    var cur = $('#selected-menu-item').parent();
    var prev = cur.prev();
    if(prev) {
        var item = prev.attr('item');
        var num = prev.attr('num');
        var url = window.location.href;
        var ind = url.indexOf('&item=');
        if(ind>0) {
            url = url.substr(0,ind);
            url = url+'&item='+item;
            if(num) {
                url = url+'&num='+num;
            }
            window.location.href = url;
        }
    }    
}
function MU_verder() {
    var cur = $('#selected-menu-item').parent();
    var prev = cur.next();
    if(prev) {
        var item = prev.attr('item');
        var num = prev.attr('num');
        var url = window.location.href;
        var ind = url.indexOf('&item=');
        if(ind>0) {
            url = url.substr(0,ind);
        }
        
        url = url+'&item='+item;
        if(num) {
            url = url+'&num='+num;
        }
        window.location.href = url;
    }
}

function M4A_ShowExampleAnswer(parent) {
    var div = $(parent).parents('.m4a-example');
    $('.example-answer-button', div).toggleClass('hidden');
    $('.m4a-answer',div).toggleClass('selected');
}

function MU_fontSelect(size) {
    var elm = $('.pageDiv').first();
    switch(size) {
        case 1: 
           elm.addClass('sizeA');
           elm.removeClass('sizeB');
           elm.removeClass('sizeC');
           break;
        case 2: 
           elm.addClass('sizeB');
           elm.removeClass('sizeA');
           elm.removeClass('sizeC');
           break;
        case 3: 
           elm.addClass('sizeC');
           elm.removeClass('sizeA');
           elm.removeClass('sizeB');
           break;
    }
    
}
/* jquery jscroll pluging */
(function($){$.fn.jScroll=function(e){var f=$.extend({},$.fn.jScroll.defaults,e);return this.each(function(){var a=$(this);var b=$(window);var c=new location(a);b.scroll(function(){a.stop().animate(c.getMargin(b),f.speed)})});function location(d){this.min=d.offset().top;this.originalMargin=parseInt(d.css("margin-top"),10)||0;this.getMargin=function(a){var b=d.parent().height()-d.outerHeight();var c=this.originalMargin;if(a.scrollTop()>=this.min)c=c+f.top+a.scrollTop()-this.min;if(c>b)c=b;return({"marginTop":c+'px'})}}};$.fn.jScroll.defaults={speed:"slow",top:10}})(jQuery);