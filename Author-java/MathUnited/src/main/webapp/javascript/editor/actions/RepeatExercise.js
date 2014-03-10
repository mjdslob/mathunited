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

define(['jquery','app/DOMgenerator'], function($,generator) {
    
    return {
        action : function(elm, params) {
            var action = params.cmd;
            var location = params.location;
            var base = elm.parents('._editor_context_base').first();
            var parent = elm.parents('.item-container',base).first();
            var doc = require('app/Document');
            if(parent.hasClass('shift-item-anchor')) {
                //does not contain an exercise, but is a reference point before any exercises in the containing element
            }
            if(action==='add') {
                var contentType = 'exercises';
                generator.getContentItem(contentType, function(html) {
                    if(!location) {
                        elm.replaceWith( $(html)); 
                    }
                    else if(location==='before'){
                        base.before( $(html) );
                    } else {
                        base.after( $(html) );
                    }
                    var uberBase = base.parents('._editor_context_base').first();
                    doc.reinit(uberBase);
                });
            } else {
                $( "#dialog-remove-item-confirm" ).dialog({
                    resizable: false,
                    height:240,
                    width:400,
                    modal: true,
                    buttons: {
                        Cancel: function() {
                            $( this ).dialog( "close" );
                        },
                        "verwijderen": function() {
                            base.remove();
                        }
                    }
                });
            }
            doc.setChanged(true);
        }
    };
});