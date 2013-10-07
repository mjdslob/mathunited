$(document).ready(function() {
    $('.exercisechoice').each(function(index, choiceElm) {
        $('.exercisechoice-header-item', choiceElm).click(function() {
             var level = $(this).attr('level');
             $('.exercisechoice-header-item', choiceElm).removeClass('active');
             $(this).addClass('active');
             $('.exercisegroup[level='+level+']', choiceElm).css('display','block');
             $('.exercisegroup[level!='+level+']', choiceElm).css('display','none');

             $('.exercisegroup[level='+level+'] .exercise-heading', choiceElm).each(function(index, elm) {
                var ex = $(this).parent();
                ex.addClass('active');
                $(this).addClass('active');
                $('.exercise-body',ex).css('display','block');
             });
        })
    });
    $('.menuDiv-inner').draggable();
    WM_setNumbering();
    //$(".menuDiv").jScroll({top:70});
/*
    $('.textref').each(function(index, refElm) {
        refElm = $(refElm);
        var ref = refElm.attr('ref');
        if(ref){
            var html = refElm.html();
            var exElm = $('.exercise[refid="'+ref+'"]');
            if(exElm.count>0) {
                var num = exElm.attr('num');
                refElm.html(html+'&nbsp;'+num);
            } else {
                refElm.html(html+'&nbsp;??');
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

function WM_setNumbering() {
    var ii = 1; var number = $('.section-container').first().attr('_base')-1;
    var ex = $('#ex-head-'+ii);
    var level=null, numberBase, highestNumber = 1;
    while(ex.length>0) {
        var ch = ex.parents('.exercisechoice');
        if(ch.length>0) {
            var exgrp = ex.parents('.exercisegroup');
            if(level) {
                if(exgrp.attr('level')==level) {
                    number = number + 1;
                } else {
                    number = numberBase;
                    level = exgrp.attr('level');
                }
            } else {
                number = number + 1;
                numberBase = number;
                level = exgrp.attr('level');
            }
        } else {
            level = null;
            number = number + 1;
            numberBase = -1;
        }
        if(highestNumber<number) highestNumber = number;
        if(level=='difficult'){
            ex.html(number+'s');
            $('#nav-ex-but-'+ii).html(number+'s');
        } else {
            ex.html(number);            
            $('#nav-ex-but-'+ii).html(number);
        }

        ii = ii+1;
        ex = $('#ex-head-'+ii,ch);
        if(ex.length==0){
            //go to new exercisegroup
            ex = $('#ex-head-'+ii);
            level = null;
            number = highestNumber;
        }
    }
}

function WM_toggleExerciseGroup(button) {
    var exchoice = $(button).parents('.exercisechoice').first();
    var exgroup = $(button).parents('.exercisegroup').first();
    if(!exgroup.hasClass("active")) return false;
    
    var newgroup = exgroup.next(); //get next group to activate
    if(newgroup.length==0){
        newgroup = $('.exercisegroup', exchoice).first();
    }
    var num = $('.exercise-heading',exgroup).first().attr('num');
    var menuexchoice = $('#nav-ex-but-'+num).parents('.menu-item-div').first();
    var menuexgroup = $('.exercisegroup-wrapper.active',menuexchoice).first();
    var menunewgroup = menuexgroup.nextAll('.exercisegroup-wrapper');
    if(menunewgroup.length==0) {
        menunewgroup = $('.exercisegroup-wrapper', menuexgroup.parent());
    }
    menunewgroup = menunewgroup.first();
    exgroup.removeClass('active');
    newgroup.addClass('active');
    menuexgroup.removeClass('active');
    menunewgroup.addClass('active');
    return true;  
}

function WM_toggleMenuExerciseGroup(button) {
    var num = $(button).attr('num');
    var button = $('#ex-head-'+num);
    var exgroup = $(button).parents('.exercisegroup').first();
    var coord = button.offset().top-90;
    if(exgroup.length==0 || WM_toggleExerciseGroup(button) ) {
        $('html,body').animate({
            scrollTop: coord},'slow');
    }
}

function WM_toggleHint(parent) {
    var parent = $(parent).parents('.hint-container').first();
    parent.toggleClass('show');
}
/* jquery jscroll pluging */
(function($){$.fn.jScroll=function(e){var f=$.extend({},$.fn.jScroll.defaults,e);return this.each(function(){var a=$(this);var b=$(window);var c=new location(a);b.scroll(function(){a.stop().animate(c.getMargin(b),f.speed)})});function location(d){this.min=d.offset().top;this.originalMargin=parseInt(d.css("margin-top"),10)||0;this.getMargin=function(a){var b=d.parent().height()-d.outerHeight();var c=this.originalMargin;if(a.scrollTop()>=this.min)c=c+f.top+a.scrollTop()-this.min;if(c>b)c=b;return({"marginTop":c+'px'})}}};$.fn.jScroll.defaults={speed:"slow",top:10}})(jQuery);
