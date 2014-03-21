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

define(['jquery','jqueryui','jqueryChosen'], function($) {
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

    function addItemOption(item, elm) {
      
        item.children().each(function() {
            addItemOption($(this),elm);
        });

        var id = item.attr('id');
        
        function writeItem(name) {
            //id is used through closure
            if(id) 
                elm.append($('<option value="'+id+'">'+name+'</option>'));
            else
                elm.append($('<option value="unknown">'+name+'</option>'));
        }
        switch(item[0].localName) {
            case 'introduction':
                writeItem('inleiding');
                break;
            case 'explore':
                writeItem('verkennen');
                break;
            case 'explanation-parent':
                break;
            case 'explanation':
                writeItem('uitleg');
                break;
            case 'exercise':
                writeItem('opgave');
                break;
            case 'theory':
                writeItem('theorie');
                break;
            case 'digest':
                writeItem('verwerken');
                break;
            case 'application':
                writeItem('toepassen');
                break;
            case 'extra':
                writeItem('practicum');
                break;
            case 'test':
                writeItem('test jezelf');
                break;
        }
    }
        
    function setItemOptions(comp, subcomp, div) {
        clearItemOptions(div);
        var elm = $('.item-choser',div);
        var args = {comp:comp, subcomp: subcomp};
        $.get(getComponentItemsURL, args,
              function(data) {
                  var sc = $('subcomponent#'+subcomp,data);
                  addItemOption(sc,elm);
                  elm.trigger('chosen:updated');
              });

    }
    function clearItemOptions(div) {
        var elm = $('.item-choser',div);
        $('option',elm).remove();
        elm.append($('<option value=""></option>'));
        elm.trigger('chosen:updated');
    }
    function setSubcomponentOptions(compId, div) {
        clearSubcomponentOptions(div);
        var elm = $('.subcomponent-choser',div);
        var mod = modules[compId];
        for(var jj=0; jj<mod.subcomponents.length;jj++) {
            var sub=mod.subcomponents[jj];
            elm.append('<option value="'+sub.id+'">'+sub.title+'</option>');
        }
        elm.trigger('chosen:updated');
    }
    function clearSubcomponentOptions(div) {
        var elm = $('.subcomponent-choser',div);
        $('option',elm).remove();
        elm.append($('<option value=""></option>'));
        elm.trigger('chosen:updated');
        clearItemOptions(div);
    }
    function setComponentOptions(threadId, div) {
        var elm = $('.component-choser',div);
        clearComponentOptions(div);
        var th = threads[threadId];
        for(var jj=0; jj<th.modules.length;jj++) {
            var mod=th.modules[jj];
            elm.append('<option value="'+mod.id+'">'+mod.name+'</option>');
        }
        elm.trigger('chosen:updated');
    }
    function clearComponentOptions(div) {
        var elm = $('.component-choser',div);
        $('option',elm).remove();
        elm.append($('<option value=""></option>'));
        elm.trigger('chosen:updated');
        clearSubcomponentOptions(div);
    }
    
    function setThreadOptions(div) {
        var elm = $('.thread-choser',div);
        for(var ii=0; ii<threads.length; ii++) {
            var th = threads[ii];
            if(th) {
                elm.append($('<option value="'+th.id+'">'+th.title+'</option>'));
/*
                var threadElm = document.createElement('div');
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
*/                
            }
        }
        
        //attach event handlers (opening/closing threads)
/*                        
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
*/        
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
            var parent = $('<div><select class="thread-choser" data-placeholder="selecteer een leerlijn..."><option value=""></option></select>'
                    +'<br/><select class="component-choser" data-placeholder="selecteer een hoofdstuk..."></select>'
                    +'<br/><select class="subcomponent-choser" data-placeholder="selecteer een paragraaf..."></select>'
                    +'<br/><select class="item-choser" data-placeholder="selecteer een item..."></select>'
                    +'</div>');
            $('.contentDiv').prepend(parent);
            setThreadOptions(parent);
            parent.dialog({width:300, height:400});
            $('.thread-choser', parent).chosen()
                .change(function(data) {
                    var id = $('.thread-choser option:selected').val();
                    setComponentOptions(id, parent);
                });
            $('.component-choser', parent).chosen()
                .change(function(data) {
                    var id = $('.component-choser option:selected').val();
                    setSubcomponentOptions(id, parent);
                });
            $('.subcomponent-choser', parent).chosen()
                .change(function(data) {
                    var compid = $('.component-choser option:selected').val();
                    var subid = $('.subcomponent-choser option:selected').val();
                    setItemOptions(compid, subid, parent);
                });
            $('.item-choser', parent).chosen();

        }
    };
});