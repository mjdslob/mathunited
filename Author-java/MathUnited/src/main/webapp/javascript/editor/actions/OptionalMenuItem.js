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

define(['jquery','app/DOMgenerator','mathjax'], function($, generator, MathJax) {
    
    return {
        action : function(elm, params) {
            var base = elm.parents('._editor_context_base').first();
            var contentType = params.item; //e.g. 'example'
            var action = params.cmd;       //'add', 'remove'
            
            if(action==='add'){
                generator.getContentItem(contentType, function(html) {
                    var newElm = $('<div/>');
                    newElm.append($(html));
                    if(params.location==='before') {
                        base.before(newElm);
                    } else {
                        base.after(newElm);
                    }
                    base.next('.m4a-editor-item.nonexistent').toggleClass('visible');
                    var doc = require('app/Document');
                    MathJax.Hub.Queue(["Typeset",MathJax.Hub,newElm[0]]);
                    doc.reinit(newElm);
                    doc.setChanged(true);
                });
            }
            if(action==='remove') {
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
                            elm.html('');
                            elm.next('.m4a-editor-item.nonexistent').toggleClass('visible');
                            var doc = require('app/Document');
                            doc.reinit(elm);
                            doc.reinit(elm.next('.m4a-editor-item.nonexistent'));
                            doc.setChanged(true);
                            $( this ).dialog( "close" );
                        }
                    }
                });
            }
            
        }
    }
});