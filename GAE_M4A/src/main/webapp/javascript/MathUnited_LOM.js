$(document).ready(function() {
    $('.exercise-heading').click(function() {
       var parent = $(this).parents('.exercise-with-heading');
       parent.toggleClass('open');
    });
    
    $(function() {
        // Apply widget
        $('.LOM-rating-widget').RatingAddOn();
    });
    
});

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

function M4A_ShowExampleAnswer(parent) {
    var div = $(parent).parents('.m4a-example');
    $('.example-answer-button', div).toggleClass('hidden');
    $('.m4a-answer',div).toggleClass('selected');
}

function LOM_toggleAnswer(parent){
    var div = $(parent).parent().parent();
    $('.answer-container',div).toggleClass('selected');
}
