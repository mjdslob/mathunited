WM_CMD_NONE = 0;
WM_CMD_LOAD_METHOD_DATA = 1;
WM_CMD_LOAD_THREAD_DATA = 2;
WM_CMD_SHOW_THREADS = 3;
WM_CMD_SHOW_COMPONENTS = 5;
WM_CMD_PUBLISH_SUBCOMPONENT=6;
WM_CMD_PUBLISH_SINGLE_THREAD = 7;
WM_CMD_SHOW_THREADS2 = 8;
WM_CMD_UPLOADQTI_SUBCOMPONENT = 9;
WM_CMD_PUBLISH_COMPONENTFILE = 10;
WM_CMD_LOAD_CONFIG_DATA = 11;

//spec:
// - method: url to methods-overview.xml file
// - threads: url to threads.xml file
// - show_thread_chooser: boolean
// - viewURL
function WM_Manager(spec) {
    this.CallStack = [];
//    this.threadsURL = spec.threadsURL;  //will be set by loadConfig()
//    this.methodURL = spec.methodURL;
    this.repo = spec.repo;
    this.thread = spec.thread;
    this.publishURL = '/Publisher/php/Publisher.php';
    this.target = 'mathunited';
}

WM_Manager.prototype.init = function() {
    this.addCommand(new WM_Command(WM_CMD_SHOW_COMPONENTS, {parent: 'pub-thread-container'}));
    this.addCommand(new WM_Command(WM_CMD_SHOW_THREADS2, {parent: 'preview-leerlijn-chooser', page:'publisher-preview-widget.html'}));
    if(document.getElementById('edit-leerlijn-chooser')){
        this.addCommand(new WM_Command(WM_CMD_SHOW_THREADS2, {parent: 'edit-leerlijn-chooser', page:'publisher-edit-widget.html'}));
    }
    this.addCommand(new WM_Command(WM_CMD_SHOW_THREADS, {parent: 'thread-container-2'}));
    this.addCommand(new WM_Command(WM_CMD_LOAD_THREAD_DATA, {}));
    this.addCommand(new WM_Command(WM_CMD_LOAD_METHOD_DATA, {}));
    this.addCommand(new WM_Command(WM_CMD_LOAD_CONFIG_DATA, {}));
    this.execute();
};

function WM_Command(code, args) {
    this.code = code;
    this.args = args;
};

WM_Manager.prototype.addCommand = function(cmd) {
   this.CallStack.push(cmd);
};

WM_Manager.prototype.continueProcessing = function() {
   var n = this.CallStack.length;
   if(n===0) {
       this.isExecuting=false;
       this.setMessage('');
       isBusyPublishing=false;
	   isBusyUploading=false;
       $('#publish-button').removeClass('disabled');
       $('#publish-button-2').removeClass('disabled');
       return;
   }
   var cmd = this.CallStack.pop();
   switch(cmd.code) {
     case WM_CMD_LOAD_METHOD_DATA:
          this.setMessage('Componentenoverzicht wordt geladen...');
          this.loadMethodData(cmd.args);   //generic: load general info from mathunited
          break;
     case WM_CMD_LOAD_THREAD_DATA:
          this.setMessage('Leerlijnen worden geladen...');
          this.loadThreads(cmd.args);
          break;
     case WM_CMD_SHOW_COMPONENTS:
          this.showComponents(cmd.args);
          break;
     case WM_CMD_SHOW_THREADS:
          this.showThreads(cmd.args);
          break;
     case WM_CMD_SHOW_THREADS2:
          this.showThreads2(cmd.args);
          break;
     case WM_CMD_PUBLISH_SUBCOMPONENT:
          this.publishSubcomponent(cmd.args);
          break;
     case WM_CMD_PUBLISH_COMPONENTFILE:
          this.publishComponentFile(cmd.args);
          break;
     case WM_CMD_PUBLISH_SINGLE_THREAD:
          this.publishSingleThread(cmd.args);
          break;
	 case WM_CMD_UPLOADQTI_SUBCOMPONENT:
          this.uploadQTISubcomponent(cmd.args);
          break;
      case WM_CMD_LOAD_CONFIG_DATA:
          this.loadConfig();
          break;
	 
     default:
          alert("Unknown command: "+cmd.code);
   }
};


WM_Manager.prototype.execute = function() {
    if(!this.isExecuting) {
        this.isExecuting=true;
        this.continueProcessing();
    }
};

WM_Manager.prototype.loadConfig = function() {
    var _this = this;
    $.get('/MathUnited/repoconfig', {repo: this.repo},
          function(data) {
              _this.threadURL = $('threadsURL',data).text();
              _this.methodURL = $('componentsURL',data).text();
              _this.continueProcessing();
          });
};


WM_Manager.prototype.setMessage = function(msg){
    $('message-box').html(msg);
};

WM_Manager.prototype.loadMethodData = function(args) {
    var _this=this;
    this.modules = [];
    $.get(this.methodURL,
          function(xml) {
              var methods = [];
              var sel = $(xml).find('method');

              sel.each(function(){
                  var method = new WM_Method({
                            name: $(this).attr('id'),
                            title:$(this).children('title').text(),
                            components: []
                        });
                  methods.push(method);

                  $(this).find('component').each(function(){
                     var comp_id = $(this).attr('id')
                     var comp_name = $(this).children('title').text();
                     var comp_file = $(this).attr('file');
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
                         subcomponents: subcomponents
                     });
                     _this.modules[comp_id]=module; //store with id as key
                     _this.modules.push(module);    //also store as array (for loops)

                  }); //close each on component
              }); //close each on method

              _this.methods = methods;
              _this.continueProcessing();
          }
    );
};

WM_Manager.prototype.loadThreads = function(args) {
    var _this = this;
    this.roots = [];
    $.get(this.threadURL,
        function(xml) {
            var threads = [];
            var sel;
            sel = $(xml).find('thread');
            if(!sel || sel.length===0) {
                 alert('Geen leerlijnen gevonden.');
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
                p.children('contentref').each(function() {
                    var ref = $(this).attr('ref');
                    var met = $(this).attr('method');
                    var mod = _this.modules[ref];
                    if(mod)  thread.addModule(mod);
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
};

WM_Manager.prototype.showComponents = function(args) {
    var div = $('#'+args.parent);
    for(var ii=0; ii<this.threads.length; ii++) {
        var th = this.threads[ii];
        if(th) {
            var threadElm = document.createElement('div');
            threadElm.className = 'thread-container';
            threadElm.id = th.id;
            div.append(threadElm);
            threadElm.innerHTML = 
                 '<div class="thread-meta">'
                +'<div class="thread-title" onclick="javascript:showThread(this)">'+th.title+'</div>'
                +'<div class="button-thread" onclick="toggleThread(this)">(alles)</div>'
                +'<div style="clear:left"></div></div><div class="thread-content">'
                +'</div>';
            var threadContentElm = $('.thread-content',$(threadElm));
            for(var jj=0; jj<th.modules.length;jj++) {
                var mod=th.modules[jj];
                var compElm = $('<div class="component-container"><div class="component" id="'+mod.id+'" onclick="javascript:toggleComponent(this)">'+mod.name+'</div></div>');
                threadContentElm.append(compElm);
                for(var kk=0; kk<mod.subcomponents.length;kk++) {
                    var subComp = mod.subcomponents[kk];
                    compElm.append($('<div class="subcomponent-container"><div class="subcomponent" onclick="javascript:toggleSubcomponent(this)" id="'+subComp.id+'">'+subComp.title+'</div></div>'));
                }
            }
        }
    }
    
    this.continueProcessing();
};

WM_Manager.prototype.showThreads = function(args) {
    var div = $('#'+args.parent);
    for(var ii=0; ii<this.threads.length; ii++) {
        var th = this.threads[ii];
        if(th) {
            var threadElm = document.createElement('div');
            threadElm.className = 'thread';
            threadElm.id = 'thread-'+th.id;
            div.append(threadElm);
            threadElm.innerHTML = 
                '<div class="thread-title" onclick="javascript:selectThread(this)">'+th.title+'</div><div style="clear:left"></div>';
        }
    }
    
    this.continueProcessing();
};

WM_Manager.prototype.showThreads2 = function(args) {
    var div = $('#'+args.parent);
    for(var ii=0; ii<this.threads.length; ii++) {
        var th = this.threads[ii];
        if(th) {
            div.append("<div class='choose-leerlijn' onclick=\"javascript:chooseThread('"+args.page+"?thread_id="+th.id+"&repo="+this.repo+"',this)\">"+th.title+"</div>");
        }
    }
    
    this.continueProcessing();
};


WM_Manager.prototype.publish = function() {
    if(isBusyPublishing) return;
    isBusyPublishing = true;    
    $('#publish-button').addClass('disabled');
    var _this = this;
    var subcomp = $('.subcomponent.selected');
    $(subcomp).each(function( index ) {
        var elm = $(this);
        var compParent = elm.parents('.component-container').first();
        var compElm = $('.component', compParent).first();
        var compId = compElm.attr('id');
        var subcompId = elm.attr('id');
        var comp = _this.modules[compId];
        for(var ii=0; ii<comp.subcomponents.length;ii++){
            var sc = comp.subcomponents[ii];
            if(sc.id===subcompId){
                _this.addCommand(new WM_Command(WM_CMD_PUBLISH_SUBCOMPONENT, {subcompId: subcompId, compId: compId, subcompRef: sc.file, compRef: comp.file, repo: _this.repo, target:_this.target}));
            }
        }
        _this.addCommand(new WM_Command(WM_CMD_PUBLISH_COMPONENTFILE, {compId: compId, compRef: comp.file, repo: _this.repo, target:_this.target}));
        
    });
    this.execute();
};

WM_Manager.prototype.uploadQTI = function() {
    if(isBusyUploading) return;
    isBusyUploading = true;    
    $('#uploadQTI-button').addClass('disabled');
    var _this = this;
    var subcomp = $('.subcomponent.selected');
    $(subcomp).each(function( index ) {
        var elm = $(this);
        var compParent = elm.parents('.component-container').first();
        var compElm = $('.component', compParent).first();
        var compId = compElm.attr('id');
        var subcompId = elm.attr('id');
        var comp = _this.modules[compId];
        for(var ii=0; ii<comp.subcomponents.length;ii++){
            var sc = comp.subcomponents[ii];
            if(sc.id===subcompId){
                _this.addCommand(new WM_Command(WM_CMD_UPLOADQTI_SUBCOMPONENT, {id: subcompId, compId: compId, ref: sc.file, repo: _this.repo, target:"pulseon"}));
            }
        }
    });
    this.execute();
};

WM_Manager.prototype.publishThread = function() {
    if(isBusyPublishing) return;
    isBusyPublishing = true;    
    $('#publish-button-2').addClass('disabled');
    var _this = this;
    var thread = $('.thread .thread-title.selected');
    $(thread).each(function( index ) {
        var elm = $(this);
        var threadParent = elm.parents('.thread').first();
        var threadId = threadParent.attr('id').replace('thread-','');
        var th = _this.threads[threadId];
        var repo = _this.repo;
        _this.addCommand(new WM_Command(WM_CMD_PUBLISH_SINGLE_THREAD, {id: threadId, repo: repo, target:_this.target}));
    });
    this.execute();
};

WM_Manager.prototype.publishComponentFile = function(args) {
    var _this = this;
    var elm = $('#'+args.id);
    elm.addClass('processing');
    $.post( this.publishURL, 
           {compId: args.compId, compRef: args.compRef, repo: args.repo, user:'mslob',passwd:'test', cmd:'publishComponentFile', target:args.target},
           function success(data, textStatus,jqXHR) {
               elm.removeClass('processing');
               elm.removeClass('selected');
               elm.addClass('published');
                _this.continueProcessing();
           }
    );
    
};

WM_Manager.prototype.publishSubcomponent = function(args) {
    var _this = this;
    var elm = $('#'+args.id);
    elm.addClass('processing');
    $.post( this.publishURL, 
           {subcompId:args.subcompId, compId: args.compId, subcompRef:args.subcompRef, compRef: args.compRef, repo: args.repo, user:'mslob',passwd:'test', cmd:'publishSubcomponent', target:args.target},
           function success(data, textStatus,jqXHR) {
               elm.removeClass('processing');
               elm.removeClass('selected');
               elm.addClass('published');
                _this.continueProcessing();
           }
    );
};

WM_Manager.prototype.uploadQTISubcomponent = function(args) {
    var _this = this;
    var elm = $('#'+args.id);
    elm.addClass('processing');
    $.post( this.publishURL, 
           {id:args.id, compId: args.compId, ref:args.ref, repo: args.repo, user:'mslob',passwd:'test', cmd:'uploadQTISubcomponent', target:args.target},
           function success(data, textStatus,jqXHR) {
               elm.removeClass('processing');
               elm.removeClass('selected');
               elm.addClass('published');
                _this.continueProcessing();
           }
    );
};

WM_Manager.prototype.publishOverview = function(repo, elmid) {
    var _this = this;
    var elm = $('#'+elmid);
    if(elm.hasClass('processing')) {
        return;
    }
    elm.addClass('processing');
    $.post( this.publishURL, 
           {repo: repo, user:'mslob',passwd:'test', cmd:'publishOverview'},
           function success(data, textStatus,jqXHR) {
               elm.removeClass('processing');
                _this.continueProcessing();
           }
    );
};

WM_Manager.prototype.publishSingleThread = function(args) {
    var _this = this;
    var elm = $('#thread-'+args.id);
    elm.addClass('processing');
    $.post( this.publishURL, 
           {thread:args.id, repo: args.repo, user:'mslob',passwd:'test', cmd:'publishThread', target:args.target},
           function success(data, textStatus,jqXHR) {
               elm.removeClass('processing');
               elm = $('.thread-title', elm);
               elm.removeClass('selected');
               elm.addClass('published');
                _this.continueProcessing();
           }
    );
};

function toggleComponent(elm) {
    var parent = $(elm).parents('.component-container').first();
    if($(elm).hasClass('selected')){
        $('.subcomponent',parent).removeClass("selected");
        $(elm).removeClass('selected');
    } else {
        $('.subcomponent',parent).addClass("selected");
        $(elm).addClass('selected');
    }
}

function toggleSubcomponent(elm) {
    $(elm).toggleClass('selected');
}

function selectThread(elm) {
    $('#thread-container-2 .selected').removeClass('selected');
    $(elm).toggleClass('selected');
}

function toggleThread(elm){
    var parent = $(elm).parents('.thread-container');
    var c = $('.component',parent).first();
    if(c.hasClass('selected')) {
        $('.component',parent).removeClass('selected');
        $('.subcomponent',parent).removeClass('selected');
    } else {
        $('.component',parent).addClass('selected');
        $('.subcomponent',parent).addClass('selected');
    }
}
function showThread(elm){
    var parent = $(elm).parents('.thread-container');
    $('.thread-content',parent).toggleClass('open');
}
;
