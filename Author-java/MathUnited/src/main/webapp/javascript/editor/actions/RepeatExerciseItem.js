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

define(['jquery'], function($) {
    
    return {
        action : function(elm, params) {
            var template = params.template;
            var action = params.cmd;
            var location = params.location;
            var doc = require('app/Document');
            
            var itemLabels = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'];
            if(!template) template='exercise-item-open-template';
            var parent = elm.parents('div[tag="items"]');
            if(action==='remove') {
                $( "#dialog-remove-item-confirm" ).dialog({
                resizable: false,
                height:240,
                width:400,
                modal: true,
                buttons: {
                    "verwijderen": function() {
                        elm.remove();
                        $('div[tag="item"]',parent).each(function(index,value) {
                            $(this).attr('label',itemLabels[index]);
                            $('.item-label',this).html(itemLabels[index]);
                        });
                        $( this ).dialog( "close" );
                    },
                    Cancel: function() {
                        $( this ).dialog( "close" );
                    }
                }
                });    
            } else {
                var base = elm.parents('._editor_context_base').first();
                if(location==='after'){
                    var option = base.after( $('<div class="_editor_context_base"><div class="_editor_option"></div></div>') );
                    var newElm = base.next();
                } else {
                    var option = base.before( $('<div class="_editor_context_base"><div class="_editor_option"></div></div>') );
                    var newElm = base.prev();
                }
                option = $('._editor_option', newElm);
                var attributes = elm.prop("attributes");
                $.each(attributes, function() {
                    if(this.name!=='id'){
                        option.attr(this.name, this.value);
                    }
                });
                //insert template
                option.append( $('#'+template).html() );
                
                //relabel
                $('div[tag="item"]',parent).each(function(index,value) {
                    $(this).attr('label',itemLabels[index]);
                    $('.item-label',this).html(itemLabels[index]);
                });
                //activate event handlers on the new content (e.g. the editor)
                doc.reinit(newElm);
            }
            doc.setChanged(true);
        }
    };
});