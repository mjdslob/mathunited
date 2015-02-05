function MU_Main() {
    this.view = new MU_View();
    this.host = "http://demonstrator.webhop.org:8080/MathUnited/";
//    this.host = "http://demonstrator.webhop.org:8080/MathUnited/";
    this.getMethodUrl = this.host + '/content/mathunited.xml';
    var parent = window.location.href;
    parent = parent.replace(this.host,'');
    this.viewComponentUrl = this.host + 'view?variant=2&parent='+escape(parent)+'&item=introduction&ref=';
    this.getThreadUrl = this.host + 'getthreads';
    this.getComponentUrl = this.host + 'getcomponent?id=';
    this.view.showLoadIcon('component-widget');
    this.loadMethodData();      //generic: load general info from mathunited
}

//thread:
//  id, info, title, components
//component:
//  id, method, name, file

MU_Main.prototype.afterLoad = function() {
    var threadId = MU_Util.URLparam('thread');
    this.view.hideLoadIcon();
    this.view.showThreadMenu(this.threads, threadId);
    this.showThread(threadId);
};

MU_Main.prototype.showThread = function(id) {
    this.view.showThread(this.threads[id]);
};

MU_Main.prototype.loadMethodData = function() {
    var _this=this;
    $.get(this.getMethodUrl,
          function(xml) {
              var methods = [];

              $(xml).find('method').each(function(){
                  var method = {name: $(this).attr('name'),
                                components: [] };
                  methods[method.name] = method;

                  $(this).find('component').each(function(){
                     var comp_id = $(this).attr('id')
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
                             var sub_name = $(this).children('title').text()
                             var sub_file = $(this).children('file').text()

                             var subcomponent =  {
                                 title: sub_name,
                                 file : sub_file
                             };
                             subcomponents.push(subcomponent);
                         });
                     }

                     method.components[comp_id]={
                         id: comp_id,
                         method: method.name,
                         name: comp_name,
                         file: comp_file,
                         state: comp_state,
                         subcomponents: subcomponents
                     }
                  }) //close each on component
              }); //close each on method

              _this.methods = methods;

              _this.loadThreads();

          }
    );
};

MU_Main.prototype.loadThreads = function() {
    var _this = this;
    $.get(this.getThreadUrl,
        function(xml) {
            var threads = [];
            $(xml).find('thread').each( function() {
                var threadId = $(this).attr('id');
                var thread = {
                    id   : threadId,
                    info : $(this).find('information').text(),
                    title: $(this).find('title').text(),
                    components : []

                };

                $(this).find('contentref').each(function() {
                    var ref = $(this).attr('ref');
                    var met = $(this).attr('method');
                    thread.components.push( _this.methods[met].components[ref] );
                }) //close each on contentref
                threads.push(thread);
                threads[threadId]=thread;
            });
            _this.threads = threads;
            _this.afterLoad();
        }
    );

};
