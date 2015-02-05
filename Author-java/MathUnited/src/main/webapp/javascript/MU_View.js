function MU_View() {
   this.container = $('#thread-container');
   $('.pageDiv').addClass('ui-corner-all');
}

MU_View.prototype.showThread = function(thread) {
    this.removeThreadElements();
    //first create html elements for the content.
    this.createThreadElements(thread);
    //add dynamic behavior
    //--------------------
    this.createWidgets();
};

MU_View.prototype.showThreadMenu = function(threads,selectedId) {
   var parent = $('#choose-thread-container');
   for(var ii=0;ii<threads.length;ii++) {
       var thread = threads[ii];
       var elm = $('<div class="mu-thread-menu-item" thread="'+thread.id+'"/>')
         .html(thread.title)
         .appendTo(parent);
       if(thread.id == selectedId) {
           elm.addClass('mu-thread-item-selected');
       }
       elm.click(function() {
           mu_main.showThread($(this).attr('thread'));
           $(this).siblings().removeClass('mu-thread-item-selected');
           $(this).addClass('mu-thread-item-selected');
       });
       elm.mouseover(function() {
           $(this).addClass('mu-thread-item-active');
       });
       elm.mouseout(function(){
           $(this).removeClass('mu-thread-item-active');
       });
   }
};

MU_View.prototype.removeThreadElements = function() {
    $('#component-widget > *').remove();   //remove old contents
};

MU_View.prototype.createThreadElements = function(thread) {
    var n = thread.components.length;
    this.container = $('#thread-info').html( thread.info );
    this.container = $('#thread-title').html( thread.title );
    var parent = $('<div id="components-container"/>').appendTo($('#component-widget'));
    parent.css('display','none');
    for(var ii=0;ii<n; ii++) {
        var comp = thread.components[ii];
        var ref = mu_main.viewComponentUrl+comp.file;
        var elm = $('<div class="header">'+comp.name+ '</div>');
        if(comp.state!='live') elm.addClass('mu-header-inactive');
        parent.append( elm );
        var contentDiv =  $('<div></div>');
        contentDiv.appendTo(parent);
        contentDiv.append($('<div class="subcomponent-header"/>').html(comp.name)).append($('<ol></ol>'));
        var nsub = comp.subcomponents.length;
        var _pelm = contentDiv.find('ol');
        for(var jj=0;jj<nsub;jj++) {
             var subc = comp.subcomponents[jj];
             if(comp.state=='live'){
                 var elm = $('<li id="li-'+subc.id+'"></li>').html(
                     '<a href="'+mu_main.viewComponentUrl+subc.file+'">'+
                     subc.title+'</a>');
             } else {
                 var elm = $('<li class="mu-subcomponent-inactive"></li>').html(subc.title);
             }
             $(_pelm).append(elm);

        }
    }
    
    parent.css('display','block');
//    $('#components-container').accordion();
};

MU_View.prototype.showLoadIcon = function(parentId) {
    var parent=$('#'+parentId);
    var loadIcon = $('<div class="load-icon"/>');
    loadIcon.appendTo(parent);
//    loadIcon.css('top','30px');
//    loadIcon.css('left','200px');
    this.loadIcon = loadIcon;
};

MU_View.prototype.hideLoadIcon = function() {
    this.loadIcon.remove();
    this.loadIcon = null;
};

MU_View.prototype.createWidgets = function() {
    var par = $('#component-widget');
    var sub_cont = $('<div id="subcomponent-container" class="ui-corner-right"/>')
            .css('float','left')
            .appendTo(par);
    $('#components-container').css('float','left');
    $('#components-container .header')
          .prepend($('<div class="ui-icon ui-icon-triangle-1-e"/>'))
          .click(function() {
                    $(this).siblings().removeClass('mu-selected');
                    $(this).addClass('mu-selected');
              })
          .mouseover(function() {
                    $(this).addClass('mu-active');
              })
          .mouseout(function() {
                    $(this).removeClass('mu-active');
              });
    var innerElm = $('<div id="subcomponent-container-inner"/>')
         .appendTo($('#subcomponent-container'));
    //add theme classes
    $('#components-container').addClass('ui-widget');
    $('#components-container .header')
                 .next('div').addClass('ui-widget-content ui-corner-all ui-helper-hidden');
    //add functionality
    $('#components-container .header').click(function() {
        var _this = this;
        innerElm.fadeOut(300, function(){
            var html = $(_this).next('div').html();
            innerElm.html(html);
            innerElm.fadeIn(300);
        });
    });

    sub_cont.css('min-height', par.height()+'px');

    //set default
    innerElm.html($('#components-container .header:first-child').next('div').html());
    $('#components-container .header:first-child').addClass('mu-selected');
};

