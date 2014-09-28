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

define(['jquery','actions/OptionalContentItem','actions/OptionalMenuItem','actions/OptionalTemplate',
                 'actions/RepeatExercise','actions/RepeatExerciseItem','actions/RepeatTemplate',
                 'actions/SetExerciseMetadata','actions/SetGeneralMetadata', 'actions/ShiftItemDown',
                 'actions/ShiftItemUp','actions/CreateCloneExercise','actions/CopyHandler',
                 'actions/ToggleAlgebraKIT'],
                 function($) {
    var insertContentItem_typeUrl = 'content-items.xml';
    var processItem_url = '/MathUnited/processitem';
    var paragraph_id_counter = 0;
    var menulistid = 0;
    var editoroptionid = 0;

    /*
     * ContextMenu - jQuery plugin for right-click context menus
     *
     * Author: Chris Domigan
     * Contributors: Dan G. Switzer, II
     * Parts of this plugin are inspired by Joern Zaefferer's Tooltip plugin
     *
     * Dual licensed under the MIT and GPL licenses:
     *   http://www.opensource.org/licenses/mit-license.php
     *   http://www.gnu.org/licenses/gpl.html
     *
     * Version: r2
     * Date: 16 July 2007
     *
     * For documentation visit http://www.trendskitchens.co.nz/jquery/contextmenu/
     *
     */

    (function($) {

      var menu, shadow, trigger, content, hash, currentTarget;
      var defaults = {
        menuStyle: {
          listStyle: 'none',
          padding: '1px',
          margin: '0px',
          backgroundColor: '#fff',
          border: '1px solid #999',
          width: '100px'
        },
        itemStyle: {
          margin: '0px',
          color: '#000',
          display: 'block',
          cursor: 'default',
          padding: '3px',
          border: '1px solid #fff',
          backgroundColor: 'transparent'
        },
        itemHoverStyle: {
          border: '1px solid #0a246a',
          backgroundColor: '#b6bdd2'
        },
        eventPosX: 'pageX',
        eventPosY: 'pageY',
        shadow : true,
        onContextMenu: null,
        onShowMenu: null
            };

      $.fn.contextMenu = function(id, options) {
        if (!menu) {                                      // Create singleton menu
          menu = $('<div id="jqContextMenu"></div>')
                   .hide()
                   .css({position:'absolute', zIndex:'500'})
                   .appendTo('body')
                   .bind('click', function(e) {
                     e.stopPropagation();
                   });
        }
        if (!shadow) {
          shadow = $('<div></div>')
                     .css({backgroundColor:'#000',position:'absolute',opacity:0.2,zIndex:499})
                     .appendTo('body')
                     .hide();
        }
        hash = hash || [];
        hash.push({
          id : id,
          menuStyle: $.extend({}, defaults.menuStyle, options.menuStyle || {}),
          itemStyle: $.extend({}, defaults.itemStyle, options.itemStyle || {}),
          itemHoverStyle: $.extend({}, defaults.itemHoverStyle, options.itemHoverStyle || {}),
          bindings: options.bindings || {},
          shadow: options.shadow || options.shadow === false ? options.shadow : defaults.shadow,
          onContextMenu: options.onContextMenu || defaults.onContextMenu,
          onShowMenu: options.onShowMenu || defaults.onShowMenu,
          eventPosX: options.eventPosX || defaults.eventPosX,
          eventPosY: options.eventPosY || defaults.eventPosY
        });

        var index = hash.length - 1;
        $(this).bind('click', function(e) {
          // Check if onContextMenu() defined
          var bShowContext = (!!hash[index].onContextMenu) ? hash[index].onContextMenu(e) : true;
          if (bShowContext) display(index, this, e, options);
          return false;
        });
        return this;
      };

      function display(index, trigger, e, options) {
        var cur = hash[index];
        content = $('#'+cur.id).find('ul:first').clone(true);
        content.css(cur.menuStyle).find('li').css(cur.itemStyle).hover(
          function() {
            $(this).css(cur.itemHoverStyle);
          },
          function(){
            $(this).css(cur.itemStyle);
          }
        ).find('img').css({verticalAlign:'middle',paddingRight:'2px'});

        // Send the content to the menu
        menu.html(content);

        // if there's an onShowMenu, run it now -- must run after content has been added
                    // if you try to alter the content variable before the menu.html(), IE6 has issues
                    // updating the content
        if (!!cur.onShowMenu) menu = cur.onShowMenu(e, menu);

        $.each(cur.bindings, function(id, func) {
          $('#'+id, menu).bind('click', function(e) {
            hide();
            func(trigger, currentTarget);
          });
        });

        menu.css({'left':e[cur.eventPosX],'top':e[cur.eventPosY]}).show();
        if (cur.shadow) shadow.css({width:menu.width(),height:menu.height(),left:e.pageX+2,top:e.pageY+2}).show();
        $(document).one('click', hide);
      }

      function hide() {
        menu.hide();
        shadow.hide();
      }

      // Apply defaults
      $.contextMenu = {
        defaults : function(userDefaults) {
          $.each(userDefaults, function(i, val) {
            if (typeof val == 'object' && defaults[i]) {
              $.extend(defaults[i], val);
            }
            else defaults[i] = val;
          });
        }
      };

    })($);

    $(function() {
      $('div.contextMenu').hide();
    });    

    return {
        init: function(jqParent) {
            var _this = this;
            //find all menu-buttons, then trace back to the _editor_context_base. Next, collect all references
            //to menu items (._editor_option). The menu itself will be created below the menu-button.
            //the following default behavior is supported
            // - type="repeat": insert (before), insert (after) and remove
            // - type="optional": add or remove a single item
            // - type="action": call a function
            // an item is defined through a template (indicated by attribute 'template'=<id>) or
            // by a function name that performs the intended action.
            $('.menu-button',jqParent).each(function(){
                if($(this).parents('.hidden-templates').length>0) return; //don't add a menu to the hidden templates

                var parent = $(this).parent('.menu-button-div');
                if(parent.length===0)return;
                parent.css('display','block');
                var base = $(this).parents('._editor_context_base').first();
                if(base.length===0) return;

                var menu = new _this.menu(parent, base);
                menu.init();
                
            });
        },
        //add a context menu at the dom-element 'parent', collecting all options that exist
        //under 'base' in the document.
        menu: function(parent, base){
            //create the menu. Every menu gets a unique id
            base.attr('num',menulistid);
            var menuid = 'menulist-'+menulistid; menulistid+=1;
            var menulist = $('<div class="contextMenu" id="'+menuid+'"><ul></ul></div>');
            $('.contextMenu',parent).remove(); //remove any pre-existing menu
            parent.append(menulist);
            menulist.css('display','none');

            return {
                base    : base,
                parent  : parent,
                menulist: menulist,
                init : function() {
                    var _this = this;
                    var items = $('._editor_option',base);
                    var itemnr = 1;
                    $(items).each(function() {
                        itemnr = _this.addMenuItem($(this), itemnr);
                    });
                    if(itemnr===1) {
                        //no options found. Don't display the button and the menu
                        parent.css('display','none');
                    } else {
                        function callAction(elm, id) {
                           var parent = $(elm).parents('.menu-button-div').first();
                           var item = $('#'+id,parent);
                           var module = require(item.attr('handler'));
                           var params = eval('('+item.attr('params')+')');
                           module.action($('#'+params.id), params);
                        }
                        //call the jquery contextmenu plugin
                        $('.menu-button',parent).contextMenu(menuid, {
                            menuStyle: {
                                width: '150px'
                            },
                            bindings: {
                               'item1': function(t) {callAction(t, 'item1');},
                               'item2': function(t) {callAction(t, 'item2');},
                               'item3': function(t) {callAction(t, 'item3');},
                               'item4': function(t) {callAction(t, 'item4');},
                               'item5': function(t) {callAction(t, 'item5');},
                               'item6': function(t) {callAction(t, 'item6');},
                               'item7': function(t) {callAction(t, 'item7');},
                               'item8': function(t) {callAction(t, 'item8');}
                            }
                        });
                    }
                },
                addMenuItem : function(elm, itemnr) {
                    var par = elm.parents('._editor_context_base').first();
                    if(par.attr('num')!==''+(menulistid-1)) return itemnr;//belongs to different base
                    var id = elm.attr('id');
                    if(!id) {
                        id = 'editor-option-'+editoroptionid;
                        editoroptionid+=1;
                        elm.attr('id',id);
                    }

                    function merge(dest, params) {
                        for(var propt in params) {
                            dest[propt] = params[propt];
                        }
                        return dest;
                    }
                    function serialize(params){
                        var str = '{';
                        var first = true;
                        for(var propt in params) {
                            if(first) {
                                first=false;
                                str += propt + ":'" + params[propt] + "'"; 
                            } else {
                                str += "," + propt + ":'" + params[propt] + "'"; 
                            }
                        }
                        str += '}';
                        return str;
                    }
                    
                    var templateName = elm.attr('name');
                    var funcStr = elm.attr('function');
                    var paramStr = elm.attr('params');
                    var params = {};
                    if(paramStr) params = eval('('+paramStr+')');
                    params['id']=id;
                    switch(elm.attr('type')) {
                        case 'repeat':
                            var grandparent = base.parents('._editor_context_base').first();
                            if(grandparent.length===0) grandparent=$('div[tag="componentcontent"]').first();
                            var min = elm.attr('min'); if(typeof min === 'undefined') min=0;
                            var max = elm.attr('max'); if(typeof max === 'undefined') max=1000;
                            var num = $('._editor_option[type="repeat"][function="'+funcStr+'"]', grandparent).length;
                            if(num===1 && elm.children().length===0) {
                                var insertparam = merge({cmd: 'add'}, params);
                            } else{
                                var insertBeforeParam = merge({cmd: 'add', location: 'before'},params);
                                var insertAfterParam = merge({cmd: 'add', location: 'after'},params);
                            }
                            var removeParam = merge({cmd: 'remove'}, params);
                            
                            if(num===1 && elm.children().length===0) {
                                $('ul',menulist).append('<li id="item'+itemnr+'" handler="'+funcStr+'" params="'+serialize(insertparam)+'">+ '+templateName+'</li>');
                            } else if(num<max && num>0){
                                $('ul',menulist).append('<li id="item'+itemnr+'" handler="'+funcStr+'" params="'+serialize(insertBeforeParam)+'">'+templateName+' (voor)</li>');
                                itemnr+=1;
                                $('ul',menulist).append('<li id="item'+itemnr+'" handler="'+funcStr+'" params="'+serialize(insertAfterParam)+'">'+templateName+' (na)</li>');
                                itemnr+=1;
                                if(num>min) {
                                    $('ul',menulist).append('<li id="item'+itemnr+'" handler="'+funcStr+'" params="'+serialize(removeParam)+'">- '+templateName+'</li>');
                                }
                            }
                            itemnr+=1;
                            break;
                        case 'optional':
                            if(elm.children().length===0) {
                                var insertparams = merge({cmd: 'add'}, params);
                                $('ul',menulist).append('<li id="item'+itemnr+'" handler="'+funcStr+'" params="'+serialize(insertparams)+'">+ '+templateName+'</li>');
                            } else {
                                var removeparams = merge({cmd: 'remove'}, params);
                                $('ul',menulist).append('<li id="item'+itemnr+'" handler="'+funcStr+'" params="'+serialize(removeparams)+'">- '+templateName+'</li>');
                            }
                            itemnr+=1;
                            break;
                        case 'action':
                            $('ul',menulist).append('<li id="item'+itemnr+'" handler="'+funcStr+'" params="'+serialize(params)+'">  '+templateName+'</li>');
                            itemnr+=1;
                            break;
                    }
                    return itemnr;
                }
            };

            
        }
    };
});