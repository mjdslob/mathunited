/* 
 * Copyright (C) 2013 Martijn Slob <m.slob@math4all.nl>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

define(['jquery','jqueryui'], function($) {
    var getComponentItemsURL = '/MathUnited/getcomponentitems';
    var isInitialized = false;
    var modules = [];
    var methods = [];
    var roots = [];
    var threads = [];
    
    function loadMethodData(url, callback) {
        $.get(url,
              function(xml) {
                  var sel = $(xml).find('method');

                  sel.each(function(){
                      var method = {
                                        name: $(this).attr('id'),
                                        title:$(this).children('title').text(),
                                        components: []
                                    };
                      methods.push(method);

                      $(this).find('component').each(function(){
                         var comp_id = $(this).attr('id');
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

                         var module = {
                             id           :comp_id,
                             name         :comp_name,
                             file         : comp_file,
                             publishState : comp_state,
                             method       : method,
                             subcomponents: subcomponents
                         };
                         modules[comp_id]=module; //store with id as key
                         modules.push(module);    //also store as array (for loops)

                      }); //close each on component
                  }); //close each on method
                  callback();
              }
        );
    }
    
    function loadThreads(url, callback) {
        $.get(url,
            function(xml) {
                var sel;
                sel = $(xml).find('thread');
                if(!sel || sel.length===0) {
                     alert('Geen leerlijnen gevonden.');
                }
                sel.each(function(){
                    var threadId = $(this).attr('id');
                    var thread = {
                        id   : threadId,
                        info : $(this).children('information').text(),
                        title: $(this).children('title').text(),
                        type : $(this).children('schooltype').text(),
                        year : $(this).children('year').text(),
                        modules : []
                    };
                    var p = $(this).children('threadsequence');
                    p.children('contentref').each(function() {
                        var ref = $(this).attr('ref');
                        var met = $(this).attr('method');
                        var mod = modules[ref];
                        if(mod)  thread.modules.push(mod);
                    }) //close each on contentref
                    threads.push(thread);
                    threads[threadId]=thread;
                });

                //retain only the modules from the threads
                for(var ii=0; ii<threads.length;ii++) {
                    var thr = threads[ii];
                    for(var jj=0; jj<thr.modules.length; jj++) {
                        var mod = thr.modules[jj];
                        if(!modules[ mod.id ]) {
                            modules[ mod.id ] = mod;
                            modules.push(mod);
                        }
                    }
                }
                callback();
            }
        );
    }

    function writeItemHTML(item) {
      
        var inner = '';
        item.children().each(function() {
            inner += writeItemHTML($(this));
        });

        var id = item.attr('id');
        
        function writeItem(name) {
            //id is used through closure
            if(id) 
                return '<div class="item-selector-item-container"><div class="item-selector-item" id="'+id+'">'+name+'</div>'+inner+'</div>';
            else
                return '<div class="item-selector-item-container"><div class="item-selector-item">'+name+'</div>'+inner+'</div>';
        }
        var result = '';
        switch(item[0].localName) {
            case 'introduction':
                result+=writeItem('inleiding');
                break;
            case 'explore':
                result+=writeItem('verkennen');
                break;
            case 'explanation-parent':
                break;
            case 'explanation':
                result+=writeItem('uitleg');
                break;
            case 'exercise':
                result+=writeItem('opgave');
                break;
            case 'theory':
                result+=writeItem('theorie');
                break;
            case 'digest':
                result+=writeItem('verwerken');
                break;
            case 'application':
                result+=writeItem('toepassen');
                break;
            case 'extra':
                result+=writeItem('practicum');
                break;
            case 'test':
                result+=writeItem('test jezelf');
                break;
        }
        return result;
    }
    
    function showSubcomponentItems(comp, subcomp,parent) {
        var args = {comp:comp, subcomp: subcomp};
        $.get(getComponentItemsURL, args,
              function(data) {
                  var sc = $('subcomponent#'+subcomp,data);
                  var itemHTML = '';
                  sc.children().each( function() {
                      itemHTML += writeItemHTML($(this));
                  });
                  parent.append($(itemHTML));
              });
    }
    
    function showComponents(div) {
        for(var ii=0; ii<threads.length; ii++) {
            var th = threads[ii];
            if(th) {
                var threadElm = document.createElement('div');
                threadElm.className = 'thread-container';
                threadElm.id = th.id;
                div.append(threadElm);
                threadElm.innerHTML = 
                     '<div class="item-selector-thread-meta">'
                    +'<div class="item-selector-thread-title">'+th.title+'</div>'
                    +'</div><div class="item-selector-thread-content">'
                    +'</div>';
                var threadContentElm = $('.item-selector-thread-content',$(threadElm));
                for(var jj=0; jj<th.modules.length;jj++) {
                    var mod=th.modules[jj];
                    var compElm = $('<div class="item-selector-component-container"><div class="item-selector-component" id="'+mod.id+'">'+mod.name+'</div></div>');
                    threadContentElm.append(compElm);
                    for(var kk=0; kk<mod.subcomponents.length;kk++) {
                        var subComp = mod.subcomponents[kk];
                        compElm.append($('<div class="item-selector-subcomponent-container"><div class="item-selector-subcomponent" id="'+subComp.id+'">'+subComp.title+'</div></div>'));
                    }
                }
            }
        }
        //attach event handlers (opening/closing threads)
        $('.item-selector-thread-title',div).click(function() {
            var parent = $(this).parents('.thread-container');
            $('.item-selector-thread-content',parent).toggleClass('open');
        });
        $('.item-selector-component',div).click(function() {
            var parent = $(this).parents('.item-selector-component-container');
            $('.item-selector-subcomponent-container',parent).toggleClass('open');
        });
        $('.item-selector-subcomponent',div).click(function() {
            var subcomp = $(this).attr('id');
            var subcompcont = $(this).parent();
            var parent = $(this).parents('.item-selector-component-container').first();
            var comp = $('.item-selector-component',parent).first().attr('id');
            showSubcomponentItems(comp, subcomp, subcompcont); 
        });
    }    

    return {
        init: function(methodURL, threadURL) {
            var _this = this;
            $('.select-item-button').click(function() {
                _this.show();
            });
            loadMethodData(methodURL, function() {
                loadThreads(threadURL, function() {
                   isInitialized = true; 
                });
            });
        },
        show: function() {
            if(!isInitialized) {alert('Probleem: kan de beschikbare paragrafen niet laden'); return; }
            var parent = $('<div></div>');
            showComponents(parent);
            parent.dialog();
        }
    };
});