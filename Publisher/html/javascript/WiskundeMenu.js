function MU_View(viewURL) {
   this.container = $('#thread-container');
   this.viewURL = viewURL;
   $('.pageDiv').addClass('ui-corner-all');
}

MU_View.prototype.showThread = function(thread) {
    this.removeThreadElements();
    //first create html elements for the content.
    this.createThreadElements(thread);
    $('#thread-title').html(thread.title);
    $('#thread-info').html(thread.info);
    //add dynamic behavior
    //--------------------
    this.createWidgets();
}

MU_View.prototype.selectModule = function(mod) {
    var elm = $('#mod-'+mod.id);
    elm.siblings().removeClass('mu-selected');
    elm.addClass('mu-selected');
    var innerElm = $('#subcomponent-container-inner');
    var html = elm.next('div').html();
    
    if(wm.view){//position list under node in bolletjesschema
        $('#subcomponent-container').css('left', ''+(mod.pos.x/wm.view.OVERSAMPLING-5)+'px')
    }
    innerElm.html(html);
/*    
    innerElm.fadeOut(300, function(){
        var html = elm.next('div').html();
        innerElm.html(html);
        innerElm.fadeIn(300);
    });
*/    

}

MU_View.prototype.showThreadMenu = function(threads,selectedId) {
   var parent = $('#choose-thread-container');
   var _this = this;
   for(var ii=0;ii<threads.length;ii++) {
       var thread = threads[ii];
       var elm = $('<div class="mu-thread-menu-item" thread="'+thread.id+'"/>')
         .html(thread.title)
         .appendTo(parent);
       if(thread.id == selectedId) {
           elm.addClass('mu-thread-item-selected');
       }
       elm.click(function() {
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
}

MU_View.prototype.removeThreadElements = function() {
    $('#component-widget > *').remove();   //remove old contents
}

MU_View.prototype.createThreadElements = function(thread) {
    var n = thread.modules.length;
    var parent = $('<div id="components-container"/>').appendTo($('#component-widget'));
    for(var ii=0;ii<n; ii++) {
        var comp = thread.modules[ii];
        var ref = this.viewURL+comp.file;
        var elm = $('<div class="header" id="mod-'+comp.id+'">'+comp.name+ '</div>');
        if(comp.publishState!='live') elm.addClass('mu-header-inactive');
        parent.append( elm );
        var contentDiv =  $('<div></div>');
        contentDiv.appendTo(parent);
        if(comp.method.name=='wm') {
            contentDiv.append($('<ol start=0></ol>'));
        } else {
            contentDiv.append($('<ol></ol>'));
        }
        var nsub = comp.subcomponents.length;
        var _pelm = contentDiv.find('ol');
        for(var jj=0;jj<nsub;jj++) {
             var subc = comp.subcomponents[jj];
             if(comp.publishState=='live'){
                 var ref=this.viewURL+'&comp='+comp.id+'&subcomp='+subc.id+'&thread='+thread.id;
                 var elm = $('<li id="li-'+subc.id+'"></li>').html(
                     '<a target="_parent" href="'+ref+'">'+subc.title+'</a>');
             } else {
                 var elm = $('<li class="mu-subcomponent-inactive"></li>').html(subc.title);
             }
             $(_pelm).append(elm);

        }
    }
}

MU_View.prototype.showLoadIcon = function(parentId) {
    var parent=$('#'+parentId);
    var loadIcon = $('<div class="load-icon"/>');
    loadIcon.appendTo(parent);
//    loadIcon.css('top','30px');
//    loadIcon.css('left','200px');
    this.loadIcon = loadIcon;
}
MU_View.prototype.hideLoadIcon = function() {
    this.loadIcon.remove();
    this.loadIcon = null;
}

MU_View.prototype.createWidgets = function() {
    var _this = this;
    var par = $('#component-widget');
    var w = $('#component-widget').width();
    var sub_cont = $('<div id="subcomponent-container" />')
            .appendTo(par);
    $('#components-container').css('float','left');
    $('#components-container .header')
          .prepend($('<div class="ui-icon ui-icon-triangle-1-e"/>'))
          .click(function() {
                    var id = $(this).attr('id').replace('mod-','');
                    var mod = wm.modules[id];
                    wm.selectModule(mod);
              })
          .mouseover(function() {
                    $(this).addClass('mu-active');
                    wm.hoverModule( ($(this)[0].id).replace("mod-",""),true);
              })
          .mouseout(function() {
                    $(this).removeClass('mu-active');
                    wm.hoverModule( ($(this)[0].id).replace("mod-",""),false);
              });
    var innerElm = $('<div id="subcomponent-container-inner"/>')
         .appendTo($('#subcomponent-container'));
    //add theme classes
    $('#components-container').addClass('ui-widget');
    $('#components-container .header')
                 .next('div').addClass('ui-widget-content ui-corner-all ui-helper-hidden');

    $('#component-widget').append(  $('<div/>').css('clear','both') );

    $('<div id="components-padding" class="header"></div>')
        .appendTo($('#components-container'));
    this.setDefaultModule();
/*
    //set default
    innerElm.html($('#components-container .header:first-child').next('div').html());
    $('#components-container .header:first-child').addClass('mu-selected');
*/    
}

MU_View.prototype.setDefaultModule = function() {
    $('#subcomponent-container-inner').html($('#components-container .header:first-child').next('div').html());
    $('#components-container .header:first-child').addClass('mu-selected');
}
var currentTabToggle = null;

$(function() {
    WM_createMenu();
    var ref=gup('tab');
    if(ref)
       WM_Toggle(ref);
    else
       WM_Toggle('TabIntro');
});


function WM_Toggle(id) {
    if(currentTabToggle){
        //currentTabToggle.style.display='none';
        currentTabToggle.style.width='1px';
        currentTabToggle.style.height='0px';
        currentTabToggle.style.display='absolute';
    }
    currentTabToggle = document.getElementById(id);
    if(currentTabToggle){
        currentTabToggle.style.width='1024px';
        currentTabToggle.style.height='100%';//768px';
        currentTabToggle.style.display='';
    }
    //currentTabToggle.style.display='block';
}

function WM_createMenu() {
    $('.tab').each(function(){
        var content = $('.content',this);
        var thisTabId = $(this).attr('id');
        content.append('<div class="wm-menu"></div>');
        var menu = $('.wm-menu',$(this));
        $('.tab').each(function(){
            var name = $(this).attr('name');
            var id=$(this).attr('id');
            var elm = $('<a id=wm-menu-"'+id+'" href="javascript:WM_Toggle(\''+id+'\')" class="wm-menu-item">'+name+'</a>');
            if(id==thisTabId){
                elm.addClass('wm-menu-active');
            }
            menu.append(elm);
        });
    });
}

function gup( name )
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


;

function WM_Link(mod1, mod2) {
    this.state = WM_MODULE_STATE_NORMAL;
    this.mod1 = mod1;
    this.mod2 = mod2;
}

WM_Link.prototype.equals = function(other) {
    if(this.mod1.id == other.mod1.id) {
        if(this.mod2.id == other.mod2.id) return true;
        return false;
    } else {
        if(this.mod1.id != other.mod2.id) return false;
        if(this.mod2.id != other.mod1.id) return false;
        return true;
    }
}
WM_Link.prototype.other = function(mod) {
    if(this.mod1.id == mod.id) return this.mod2;
    if(this.mod2.id == mod.id) return this.mod1;
    return null;
}
;WM_CMD_NONE = 0;
WM_CMD_LOAD_METHOD_DATA = 1;
WM_CMD_LOAD_THREAD_DATA = 2;
WM_CMD_SHOW_THREAD = 5;
WM_CMD_INIT_VIEWS = 6;
WM_CMD_INIT_CANVAS = 7;
WM_CMD_LOAD_WORKFLOW_DATA = 8;

//spec:
// - method: url to methods-overview.xml file
// - threads: url to threads.xml file
// - show_thread_chooser: boolean
// - viewURL
function WM_Manager(spec) {
    this.CallStack = [];
    this.isExecuting=false;
    this.show_thread_chooser = spec.show_thread_chooser;
    this.view = null;        // views will be initialized when DOM is loaded
    this.threadView = null;  //
    this.viewURL = spec.viewURL;
    this.filter = spec.filter;
    if(!this.filter) this.filter = '';
    this.threadsURL = spec.threadsURL;
    this.threadId = spec.threadId;
    this.methodURL = spec.methodURL;
    this.methodId = spec.methodId;
    this.workflowURL = spec.workflowURL;
}

WM_Manager.prototype.init = function() {
    if(this.workflowURL) this.addCommand(new WM_Command(WM_CMD_LOAD_WORKFLOW_DATA, {}));
    if(this.show_thread_chooser){
        this.addCommand(new WM_Command(WM_CMD_INIT_CANVAS, this.filter));
    }
    this.addCommand(new WM_Command(WM_CMD_SHOW_THREAD, null));
    this.addCommand(new WM_Command(WM_CMD_INIT_VIEWS, null));
    this.addCommand(new WM_Command(WM_CMD_LOAD_THREAD_DATA, {url: this.threadsURL, threadId: this.threadId, filter:this.filter}));
    this.addCommand(new WM_Command(WM_CMD_LOAD_METHOD_DATA, {url: this.methodURL, methodId: this.methodId}));
    this.execute();
}

function WM_Command(code, args) {
    this.code = code;
    this.args = args;
}

WM_Manager.prototype.addCommand = function(cmd) {
   this.CallStack.push(cmd);
}

WM_Manager.prototype.continueProcessing = function() {
   var n = this.CallStack.length;
   if(n==0) {
       this.isExecuting=false;
       this.setMessage('');
       return;
   }
   var cmd = this.CallStack.pop();
   switch(cmd.code) {
     case WM_CMD_INIT_CANVAS:
          this.initCanvas(cmd.args);
          this.continueProcessing();
          break;
     case WM_CMD_LOAD_METHOD_DATA:
          this.setMessage('Componentenoverzicht wordt geladen...');
          this.loadMethodData(cmd.args);   //generic: load general info from mathunited
          break;
     case WM_CMD_LOAD_THREAD_DATA:
          this.setMessage('Leerlijnen worden geladen...');
          this.loadThreads(cmd.args);
          break;
     case WM_CMD_SHOW_THREAD:
          this.setMessage('');
          var thread = this.threads[0];
          this.threadView.showThread(thread);
          this.continueProcessing();
          break;
     case WM_CMD_INIT_VIEWS:
          this.initViews();
          break;
     case WM_CMD_LOAD_WORKFLOW_DATA:
          this.loadWorkflowStatus(cmd.args);
          break;
     default:
          alert("Unknown command: "+cmd.code);
   }
}

WM_Manager.prototype.execute = function() {
    if(!this.isExecuting) {
        this.isExecuting=true;
        this.continueProcessing();
    }
}


WM_Manager.prototype.setMessage = function(msg){
    $('message-box').html(msg);
}

WM_Manager.prototype.loadWorkflowStatus = function() {
    var _this = this;
    $.get(this.workflowURL,
       function(xml) {
           $('subcomp',xml).each(function() {
              var elm = $(this);
              var descr='';
              switch(elm.attr('status')) {
                  case 'unknown': descr='In bewerking'; break;
                  case 'bewerking': descr='In bewerking'; break;
                  case 'auteur_gereed': descr='Auteur gereed'; break;
                  case 'coauteur_gereed': descr='Co-auteur gereed'; break;
                  case 'assets_gereed': descr='Assets gereed'; break;
                  case 'eindredactie_gereed': descr='Eindredactie gereed'; break;
                  case 'productie_gereed': descr='Klaar voor productie'; break;
              }
              
              $('#li-'+elm.attr('id')).prepend($('<div class="subcomp-status-wrapper"><div class="hover-text">'+descr+'</div><div class="subcomp-status '+elm.attr('status')+'"></div></div>'));
           });
           _this.threadView.setDefaultModule();
           _this.continueProcessing();
       }
    );
}

WM_Manager.prototype.initViews = function() {
    var _this = this;
    $(function() {
        _this.threadView = new MU_View(_this.viewURL);
        if(_this.show_thread_chooser){
            _this.view = new WM_View();
        }
        _this.continueProcessing();
    });
}

WM_Manager.prototype.initCanvas = function(filter) {
    try {
       if(filter) {
           this.view.setTitle(filter.niveau[0] + ' leerjaar ' + filter.jaar[0])
       } else {
           this.view.setTitle('');
       }
       this.view.setModules(this.modules);
       this.view.drawModules();
       this.selectModule(this.modules[0]);
    } catch(error) {
        //alert('Er is een fout opgetreden');
        var debug = document.getElementById('debug');
        debug.innerHTML='Een fout is opgetreden: Foutnaam: '+error.name+'. Melding: '+error.message+'<br/>line:'+error.lineNumber
          +'<br/>file: '+error.fileName;
    }
}
WM_Manager.prototype.loadMethodData = function(args) {
    var _this=this;
    this.modules = [];
    $.get(args.url,
          function(xml) {
              var methods = [];

              var sel;
              if(args.methodId) {
                  sel = $(xml).find('method[id='+args.methodId+']');
              } else {
                  sel = $(xml).find('method');
              }

              sel.each(function(){
                  var method = new WM_Method({
                            name: $(this).attr('id'),
                            title:$(this).children('title').text(),
                            components: []
                        });
                  methods.push(method);

                  $(this).find('component').each(function(){
                     var comp_id = $(this).attr('id');
                     var path = $(this).attr('basePath')+$(this).attr('relativePath');
                     var comp_name = $(this).children('title').text()
                     var comp_file = $(this).children('file').text()
                     var elm_state = $(this).children('state');
                     if(elm_state) {
                         var comp_state = elm_state.attr('type');
                     }
                     if(!comp_state) comp_state='underconstruction';
                     var sc = $(this).find('subcomponents');
                     var subcomponents = [];
                     if(sc) {
                         sc.find('subcomponent').each(function(){
                             var sub_name = $(this).children('title').text();
                             var sub_file = $(this).children('file').text();
                             var sub_id = $(this).attr('id');

                             var subcomponent =  {
                                 title: sub_name,
                                 file : sub_file,
                                 id : sub_id
                             };
                             subcomponents.push(subcomponent);
                         });
                     }
                     
                     var module = new WM_Module({
                         id           :comp_id,
                         name         :comp_name,
                         file         : comp_file,
                         publishState : comp_state,
                         method       : method,
                         path         : path,
                         subcomponents: subcomponents
                     });
                     _this.modules[comp_id]=module; //store with id as key
                     _this.modules.push(module);    //also store as array (for loops)

                  }) //close each on component
              }); //close each on method

              _this.methods = methods;
              _this.continueProcessing();
          }
    );
}

WM_Manager.prototype.loadThreads = function(args) {
    var _this = this;
    var years = args.filter['jaar'];
    var types = args.filter['niveau'];
    this.roots = [];
    $.get(args.url,
        function(xml) {
            var threads = [];
            var sel;
            if(args.threadId) {
                sel = $(xml).find('thread[id='+args.threadId+']');
                if(!sel || sel.length==0) {
                    alert('Geen leerlijnen gevonden die voldoen aan criterium "'+args.threaId+'".');
                }
            } else {
                sel = $(xml).find('thread');
                /*
                sel = $(xml).find('thread').filter(function() {
                        //check if this thread matches the filter
                        var year = $(this).children('year').text();
                        var type = $(this).children('schooltype').text();
                        var ii = 0;
                        while( ii<years.length && year.indexOf(years[ii])==-1 ) ii++;
                        if(ii==years.length) return false;
                        ii=0;
                        while( ii<types.length && types[ii] != type ) ii++;
                        if(ii==types.length) return false;
                        return true;
                });
                */
                if(!sel || sel.length==0) {
                    alert('Geen leerlijnen gevonden.');
                }
            }
            sel.each(function(){
                var threadId = $(this).attr('id');
                var thread = new WM_Thread({
                    id   : threadId,
                    info : $(this).children('information').text(),
                    title: $(this).children('title').text(),
                    type : $(this).children('schooltype').text(),
                    year : $(this).children('year').text()
                });
                var p = $(this).children('threadsequence');
                var first = true;
                p.children('contentref').each(function() {
                    var ref = $(this).attr('ref');
                    var met = $(this).attr('method');
                    var ii=0;
                    while(ii<_this.methods.length && _this.methods[ii].name!=met) ii++;
                    var mod = _this.modules[ref];
                    if(mod) {
                        thread.addModule(mod);
                        mod.addThread(thread);
                        if(first) {
                            _this.roots.push(mod);
                        }
                        first = false;
                    }
                }) //close each on contentref
                threads.push(thread);
                threads[threadId]=thread;
            });
            _this.threads = threads;
           
            //retain only the modules from the threads
            _this.modules = [];
            for(var ii=0; ii<_this.threads.length;ii++) {
                var thr = _this.threads[ii];
                for(var jj=0; jj<thr.modules.length; jj++) {
                    var mod = thr.modules[jj];
                    if(!_this.modules[ mod.id ]) {
                        _this.modules[ mod.id ] = mod;
                        _this.modules.push(mod);
                    }
                }
            }
            
            _this.continueProcessing();
        }
    );
}

WM_Manager.prototype.hoverModule = function(id,active) {
    if(this.view) this.view.hoverModule(this.modules[id],active);
}
WM_Manager.prototype.selectModule = function(module) {
    if(this.view)  this.view.selectModule(module);
    this.threadView.selectModule(module);
}
;
//a provider delivers content.
function WM_Method(spec) {
    this.name = spec.name;
    this.title = spec.title;
    this.ypos = spec.id;
}
;
//a module represents one element of learning content (aggregation level 2)
WM_MODULE_STATE_NORMAL = 1;
WM_MODULE_STATE_HOVER  = 2;


//spec = name, href
function WM_Module(spec) {
    if(spec.name) this.name = spec.name; else this.name='<unnamed>';
    if(spec.href) this.href = spec.href; else this.href='<nolink>';
    if(spec.id)   this.id = spec.id; else this.id=-1;
    if(spec.method) this.method = spec.method; else this.method='<no provider>';
    if(spec.subcomponents) this.subcomponents = spec.subcomponents; else this.subcomponents = [];
    if(spec.publishState) this.publishState = spec.publishState;
    if(spec.path) this.path = spec.path;
    this.selected = false;
    this.threads = [];
    this.pos = {x:0,y:0};
    this.pre = [];
    this.post = [];
    this.state = WM_MODULE_STATE_NORMAL;
    this.colors = ['rgb(230,230,256)','rgb(230,256,230)','rgb(256,230,230)','rgb(230,256,256)','rgb(256,230,256)','rgb(256,256,230)'];
}
WM_Module.prototype.addThread = function(thread) {
    this.threads.push(thread);
}

WM_Module.prototype.addPostLink = function(link) {
    for(var jj=0;jj<this.post.length;jj++) {
        if( this.post[jj].equals(link) ) break;
    }
    if(jj==this.post.length) {  //unknown precondition: add it
        this.post.push( link );
    }
}

WM_Module.prototype.addPreLink = function(link) {
    for(var jj=0;jj<this.pre.length;jj++) {
        if( this.pre[jj].equals(link) ) break;
    }
    if(jj==this.pre.length) {  //unknown precondition: add it
        this.pre.push( link );
    }
}

WM_Module.prototype.calcPositions = function(base) {
    this.pos = {x: base.x, y: base.y+ 0.5*wm.view.LINE_DISTANCE};
    var endpos = this.pos.x+wm.view.MODULE_DISTANCE+2*wm.view.MODULE_RADIUS;
    for(var ii=0;ii<this.post.length;ii++){
        var modAfter = this.post[ii].other(this);
        if(modAfter.pos.x<endpos) {
            var newBase = {x: endpos, y: base.y};
            modAfter.calcPositions(newBase);
        }
    }
}

WM_Module.prototype.setSelected = function(isSelected) {
    this.selected = isSelected;
    for(var jj=0; jj<this.pre.length; jj++) this.pre[jj].selected = isSelected;
    for(var jj=0; jj<this.post.length; jj++) this.post[jj].selected = isSelected;
}

WM_Module.prototype.getColor = function(state,selected) {
    if(state==null) state = this.state;
    if(selected==null) selected= this.selected;

    switch(state) {
         case WM_SEGMENT_STATE_NORMAL:
             if(selected) return wm.view.SEGMENT_COLOR_SELECTED;
             else              return wm.view.SEGMENT_COLOR_NORMAL;
             break;
         case WM_SEGMENT_STATE_HOVER:
             return wm.view.SEGMENT_COLOR_HOVER;
             break;
         return 'rgb(0,0,0)';
    }
}
WM_Module.prototype.getTextColor = function(state,selected) {
    if(state==null) state = this.state;
    if(selected==null) selected= this.selected;

    switch(state) {
         case WM_SEGMENT_STATE_NORMAL:
             if(selected) return wm.view.SEGMENT_TEXT_COLOR_HOVER;
             else         return wm.view.SEGMENT_TEXT_COLOR_NORMAL;
             break;
         case WM_SEGMENT_STATE_HOVER:
             return wm.view.SEGMENT_TEXT_COLOR_HOVER;
             break;
         return 'rgb(0,0,0)';
    }
}


WM_Module.prototype.draw = function(ctx) {
     ctx.fillStyle='rgb(255,255,255)';
     ctx.beginPath();
     ctx.arc(this.pos.x, this.pos.y, wm.view.MODULE_RADIUS, 0, 2*Math.PI,true);
     ctx.fill();
     this.drawPreline(ctx);
     ctx.strokeStyle=this.getColor();
     ctx.beginPath();
     ctx.moveTo(this.pos.x+wm.view.MODULE_RADIUS, this.pos.y);
     ctx.arc(this.pos.x, this.pos.y, wm.view.MODULE_RADIUS, 0, 2*Math.PI,true);
     //draw module title
     ctx.font = wm.view.MODULE_TEXT_FONT;
     var ang = wm.view.MODULE_TEXT_ANGLE;
     var dx = Math.cos(ang)*this.pos.x;
     var dy = Math.sin(ang)*this.pos.x;
     ctx.translate(this.pos.x+wm.view.MODULE_RADIUS*1.5, this.pos.y-wm.view.MODULE_RADIUS*1.5)
     ctx.rotate(ang);
     ctx.fillStyle = this.getTextColor();
     ctx.fillText(this.name, 0, 0);
     ctx.rotate(-ang);
     ctx.translate(-this.pos.x-wm.view.MODULE_RADIUS*1.5, -this.pos.y+wm.view.MODULE_RADIUS*1.5)
     
     ctx.stroke();
}
WM_Module.prototype.drawPreline = function(ctx) {
     for(var ii=0;ii<this.pre.length;ii++){
         //highest state prevails: hover over normal
         var link = this.pre[ii];
         var otherMod = link.other(this);
         ctx.strokeStyle=wm.view.SEGMENT_COLOR_NORMAL;
         ctx.beginPath();
         var d = [this.pos.x-otherMod.pos.x,this.pos.y-otherMod.pos.y];
         var scale = 1/Math.sqrt(d[0]*d[0]+d[1]*d[1]);
         d[0] *= scale;d[1]*=scale;
         ctx.moveTo(otherMod.pos.x+d[0]*wm.view.MODULE_RADIUS, otherMod.pos.y+d[1]*wm.view.MODULE_RADIUS);
         ctx.lineTo(this.pos.x-d[0]*wm.view.MODULE_RADIUS, this.pos.y-d[1]*wm.view.MODULE_RADIUS);
         ctx.stroke();
     }
}

//returns [x,y,width, height]
WM_Module.prototype.getBoundingBox = function() {
    var dist=wm.view.MODULE_RADIUS+wm.view.MODULE_THICKNESS+1;
    return [
        this.pos.x-dist,
        this.pos.y-dist,
        2*dist,2*dist
    ]
}

WM_Module.prototype.hover = function() {
    var div = document.getElementById('module-hover-div');
    div.innerHTML = '<b>'+this.name+'</b><br>'+this.method.title+'<br>';
    div.style.top = ''+(this.pos.y+wm.view.MODULE_HOVER_OFFSET.y+wm.view.canvas.offsetTop)+'px';
    div.style.left = ''+(this.pos.x+wm.view.MODULE_HOVER_OFFSET.x)+'px';
    div.style.zIndex = '5';
    div.style.visibility='visible';
}
WM_Module.prototype.hoverOff = function() {
    var div = document.getElementById('module-hover-div');
    div.style.top = '0px';
    div.style.left = '0px';
    div.style.zIndex = '-5';
    div.style.visibility='hidden';
}
;
//raster is a (lower resolution) representation of the canvas. Used to track
//which elements are visible on what part of the canves. Nedessary to enable
//mouse clicks, hovering, etc.
var pitch = {x:3,y:3}
function Raster(width,height) {
    this.width = width/pitch.x;
    this.height = height/pitch.y;
    this.pix = new Array(Math.ceil(this.width));
    for(var ii=0;ii<this.width;ii++) {
        this.pix[ii] = new Array(Math.ceil(this.height));
    }
}
Raster.prototype.reset = function() {
    for(var ii=0;ii<this.width;ii++) {
        this.pix[ii] = new Array(Math.ceil(this.height));
    }
}
Raster.prototype.addItem = function(item,shift) {
    var posArr = item.getBoundingBox();
    var bx = Math.floor(0.5+(posArr[0]-shift.x)/pitch.x);
    var by = Math.floor(0.5+(posArr[1]-shift.y)/pitch.y);
    var bw = Math.ceil( posArr[2]/pitch.x);
    var bh = Math.ceil( posArr[3]/pitch.y);
    for(var ii=bx;ii<bx+bw;ii++) {
        if(ii<this.width && ii>=0) {
            var col = this.pix[ii];
            for(var jj=by;jj<by+bh;jj++) {
                if(jj<this.height && jj>=0) {
                    col[jj] = item;
                }
            }
        }
    }
    //add textbox
    bx+=wm.view.MODULE_RADIUS*1.5/pitch.x;
    by-=wm.view.MODULE_RADIUS*1.5/pitch.y;
    var textwidth = wm.view.ctx.measureText(item.name, wm.view.MODULE_TEXT_FONT);
    textwidth = Math.ceil(textwidth.width*3/pitch.x);//don't know why I need factor 3
    for(var ii=0;ii<textwidth;ii++) {
        for(var jj=0;jj<bh;jj++) {
            var xx = Math.round(bx+Math.cos(wm.view.MODULE_TEXT_ANGLE)*ii-Math.sin(wm.view.MODULE_TEXT_ANGLE)*jj);
            var yy = Math.round(by+Math.sin(wm.view.MODULE_TEXT_ANGLE)*ii+Math.cos(wm.view.MODULE_TEXT_ANGLE)*jj);
            if(xx<this.width && xx>=0) {
                var col = this.pix[xx];
                if(yy<this.height && yy>=0) {
                    col[yy] = item;
                }
            }
        }
    }
    

}
Raster.prototype.getItem = function(x,y) {
    x = Math.round(x/pitch.x);
    y = Math.round(y/pitch.y);
    if(x>=0 && y>=0 && x<this.width && y<this.height) {
        return this.pix[x][y];
    }
    return null;
}

;
//a segment represents a chain of modules that need to be traversed completely
//it contains a definition of the containing modules and defines the preconditions
//a precondition is a list of chains. This chain is 'allowed' if at least one of
//the chains in the preconditions is traversed.

//note: the constructor registers this segment to the 'post' of precondition segments
//      de-register them if a segment is ever deleted
//spec = provider_id, preconds
// provider --> int
// preconds --> array of WM_Module
// modules --> array of WM_Module
//
// A segment has the functionality to draw itself.
WM_SEGMENT_STATE_NORMAL   = 1;
WM_SEGMENT_STATE_HOVER    = 2;

function WM_Segment(spec) {
    this.method = spec.method;
    this.modules=[];
    this.state = WM_SEGMENT_STATE_NORMAL;
    if(spec.modules){
        for(var ii=0;ii<spec.modules.length;ii++) {
            spec.modules[ii].parent=this;
            this.modules.push(spec.modules[ii]);
        }
    }
    this.pos = {x:0, y:0}; //positions will be calculated the first time the segment is drawn
}

WM_Segment.prototype.setSelected = function(isSelected) {
    for(var ii=0; ii<this.modules.length; ii++) {
        this.modules[ii].setSelected(isSelected);
    }
}

WM_Segment.prototype.calcPositions = function(base) {
    this.pos = {x: base.x, y: base.y+ (this.method.displayLine+0.5)*wm.view.LINE_DISTANCE};
    var endpos = this.pos.x+(this.modules.length+1)*wm.view.MODULE_DISTANCE+2*this.modules.length*wm.view.MODULE_RADIUS;
    var lastMod = this.modules[this.modules.length-1];
    for(var ii=0;ii<lastMod.post.length;ii++){
        var sgmAfter = lastMod.post[ii].other(lastMod).parent;
        if(sgmAfter.pos.x<endpos) {
            var newBase = {x: endpos, y: base.y};
            sgmAfter.calcPositions(newBase);
        }
    }
    //set positions of the modules
    var dx = 0;
    if(this.modules.length>1)
       dx =  (endpos-this.pos.x-2*wm.view.MODULE_RADIUS*this.modules.length)/(this.modules.length+1);
    for(var ii=0;ii<this.modules.length;ii++){
        this.modules[ii].pos = {x:this.pos.x + ii*dx + (2*ii+1)*wm.view.MODULE_RADIUS, y:this.pos.y};
    }
}

WM_Segment.prototype.draw = function(ctx, raster) {
    for(var ii=0;ii<this.modules.length;ii++) {
        this.modules[ii].draw(ctx);
        raster.addItem(this.modules[ii],wm.view.CANVAS_MODULE_SHIFT);
    }
}


;
//
//  id   :
//  info : beschrijving (korte zin)
//  title:
//  type : bijv HAVO-2
//  year : leerjaar
//  components : [],
//  segments: []


function WM_Thread(spec) {
    this.id = spec.id;
    this.info = spec.info;
    this.title = spec.title;
    this.type = spec.type;
    this.year = spec.year;
    this.modules = [];
}

WM_Thread.prototype.addModule = function(mod) {
    if(mod){
        var modBefore = null;
        var link = null;
        if(this.modules.length>0) {
            modBefore = this.modules[this.modules.length-1];
            link = new WM_Link(mod, modBefore);
        }
        this.modules.push(mod);
        if(link) {
            mod.addPreLink(link);
            modBefore.addPostLink(link);
        }
    }
}
;function WM_View() {
    this.OVERSAMPLING = 2;//to compensate for bad text quality
    this.LINE_DISTANCE = 40*this.OVERSAMPLING; 
    this.MODULE_DISTANCE = 30*this.OVERSAMPLING;
    this.MODULE_RADIUS=8*this.OVERSAMPLING;
    this.MODULE_THICKNESS = 3*this.OVERSAMPLING;
    this.SEGMENT_COLOR_HOVER = '#CC0000';
    this.SEGMENT_COLOR_SELECTED = '#CC0000';//rgb(0,150,0)';
    this.SEGMENT_COLOR_NORMAL = '#8cdb24';
    this.SEGMENT_TEXT_COLOR_NORMAL = '#6060A8';
    this.SEGMENT_TEXT_COLOR_HOVER = '#CC0000';
    this.MODULE_HOVER_OFFSET = {x:5, y:20};
    this.MODULE_TEXT_ANGLE = -Math.PI*.25;
    this.MODULE_TEXT_FONT = 'bold 28px Helvetica';//including oversampling
    this.CANVAS_MODULE_SHIFT = {x:30*this.OVERSAMPLING, y:10*this.OVERSAMPLING}; //shift from lower left top of canvas
    this.canvas = document.getElementById('canvas');

    // implement oversampling
    var c = $(this.canvas);
    var cw = c.attr('width');
    var ch = c.attr('height');
    c.attr('width',2*cw);
    c.attr('height',2*ch);
    c.css('width',cw); c.css('height',ch);
    
    //disable hover effect on touchscreens
    try {
        document.createEvent("TouchEvent");
        this.touchScreen = true;
    } catch (e) {
        this.touchScreen = false;
    }
    
    if (this.canvas.getContext) {
        this.ctx = this.canvas.getContext("2d");
    } else {
        this.ctx=null;
        alert('Uw browser wordt helaas niet ondersteund. U dient eerst uw browser te updaten naar de nieuwste versie.');
        return;
    }
    var canvasPos = $(this.canvas).offset();
    var hoveredItem = null;
    var _this = this;
    this.raster = new Raster(this.canvas.offsetWidth*this.OVERSAMPLING-this.CANVAS_MODULE_SHIFT.x,this.canvas.offsetHeight*this.OVERSAMPLING-this.CANVAS_MODULE_SHIFT.y);

    var getPosition = function(e) {
        e = e || window.event;
        var cursor = {x:0, y:0};
        if (e.pageX || e.pageY) {
            cursor.x = e.pageX;
            cursor.y = e.pageY;
        } else {
            cursor.x = e.clientX + 
                    (document.documentElement.scrollLeft || document.body.scrollLeft) -
                    document.documentElement.clientLeft;
            cursor.y = e.clientY +
                    (document.documentElement.scrollTop ||  document.body.scrollTop) -
                    document.documentElement.clientTop;
        }
        
        cursor.x-=canvasPos.left;
        cursor.y-=canvasPos.top;
        cursor.x*=_this.OVERSAMPLING;
        cursor.y*=_this.OVERSAMPLING;
        return cursor;
    }

    //add mouse events to the canvas
    var ev_mousemove = function(ev) {
      if (_this.touchScreen) return;
      var x, y;
      // Get the mouse position relative to the canvas element.
      var cursor = getPosition(ev);
      x = cursor.x; y = cursor.y; 
      var item = _this.raster.getItem(x-_this.CANVAS_MODULE_SHIFT.x,y-_this.CANVAS_MODULE_SHIFT.y);
      var redrawNeeded = false;
      if(hoveredItem && item!=hoveredItem) {
          hoveredItem.state = WM_SEGMENT_STATE_NORMAL;
          //redrawNeeded = true;
          hoveredItem.hoverOff();
          $('#mod-'+hoveredItem.id).removeClass('module-hovered');
      }
      hoveredItem = item;
      if(item!=null) {
          //if (!item.selected) item.hover();
          $('#mod-'+item.id).addClass('module-hovered');
          item.state = WM_SEGMENT_STATE_HOVER;
          wm.selectModule(item);
      }

      if(redrawNeeded) {
          _this.drawModules();
      }
    }

    var ev_mouseclick = function(ev) {
      var x, y;
      // Get the mouse position relative to the canvas element.
      var cursor = getPosition(ev);
      x = cursor.x; y = cursor.y;
      var item = _this.raster.getItem(x-_this.CANVAS_MODULE_SHIFT.x,y-_this.CANVAS_MODULE_SHIFT.y);
      if(item!=null) {
          wm.selectModule(item);
      }
    }
    var ev_mouseOut = function(ev) {
      if(hoveredItem) {
          hoveredItem.state = WM_SEGMENT_STATE_NORMAL;
          redrawNeeded = true;
          hoveredItem.hoverOff();
          $('#mod-'+hoveredItem.id).removeClass('module-hovered');
          hoveredItem = null;
      }
    }

    this.canvas.addEventListener('mousemove', ev_mousemove, false);
    this.canvas.addEventListener('click', ev_mouseclick, false);
    this.canvas.addEventListener('mouseout', ev_mouseOut, false);
}
 
WM_View.prototype.selectModule = function(mod) {
    var modId = mod.id;
    for(var ii=0;ii<this.modules.length; ii++) {
        this.modules[ii].selected = (this.modules[ii].id==modId);
    }
    this.drawModules();
}
WM_View.prototype.setModules = function(modules) {
    if(!this.ctx) return;
    if(!modules || modules.length==0) return;
    this.modules = modules;
    //get root segments (having no preconditions)
    this.roots = [];
    for(var ii=0;ii<modules.length;ii++) {
        if(modules[ii].pre.length==0){
            this.roots.push(modules[ii]);
        }
    }
    //calc position for each segment
    var shiftx = this.CANVAS_MODULE_SHIFT.x;
    var shifty = this.canvas.height-2*(this.MODULE_RADIUS+this.MODULE_THICKNESS)-this.CANVAS_MODULE_SHIFT.y;
    for(var ii=0;ii<this.roots.length;ii++){
        var base = {x:shiftx, y:shifty};
        this.roots[ii].calcPositions(base);
    }
    this.raster.reset();

    for(var ii=0;ii<this.modules.length;ii++){
        this.raster.addItem(this.modules[ii],wm.view.CANVAS_MODULE_SHIFT);
    }
}

WM_View.prototype.drawModules = function(){
    if(!this.ctx) return;
    this.ctx.clearRect(0,0,this.canvas.width,this.canvas.height);
    this.ctx.lineWidth = this.MODULE_THICKNESS;
    //draw segments
    for(var ii=0;ii<wm.modules.length;ii++) {
        wm.modules[ii].draw(this.ctx, this.raster);
    }
}

WM_View.prototype.setTitle = function(title) {
    $('#leerlijn-chooser-titel').html(title);
}

WM_View.prototype.threadSelected = function(thread) {
    $('#thread-title').html(thread.title);
    $('#thread-info').html(thread.info);
    $('#leerlijn-submit').attr('href',wm.ShowThreadURL+thread.id);
}

var _mod = null;
WM_View.prototype.hoverModule = function(mod,active) {
    if(!active) {
        mod.state = WM_MODULE_STATE_NORMAL;
        _mod = null;
    } else {
        if(_mod==mod) return;
        //mod.state = WM_MODULE_STATE_NORMAL;
        mod.state = WM_MODULE_STATE_HOVER;
        if(_mod!=null) _mod.state = WM_MODULE_STATE_NORMAL;
        _mod = mod;
    }
    this.drawModules();
}
;
