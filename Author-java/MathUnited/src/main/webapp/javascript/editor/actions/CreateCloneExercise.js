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
    
    $('.metadata-container .close-metadata-button').each(function() {
        
    });
    return {
        action : function(elm, params) {
            var doc = require('app/Document');
            var base = elm.parents('._editor_context_base').first();
            var parent = elm.parents('.item-container',base).first();
            //remove editors first (we cannot copy tinymce, because id's need to be unique)
            $('div.tiny-editor',parent).each(function() {
                var thisElm = $(this);
                var dest = $(this).parent();
                thisElm.children().appendTo(dest);
                thisElm.remove();
            });
            $('._editor_context_base',parent).removeAttr('num');
            $('.contextMenu',parent).remove();
            $('._editor_option').removeAttr('id');
            var cpy = parent.clone();
            var container = $('<div class="exercise-container" clone="true"></div>');
            container.append(cpy);
            parent.after(container);
            //change id's
            var idelm = $('div[tag="include"]',cpy).first();
            var id = idelm.attr('filename').replace('.xml','');
            var counter=1;
            var newid = id+'-clone-'+counter;
            var dum = $('div[tag="include"][filename="'+newid+'"]');
            if(dum.length>0) {
                counter++;
                newid = id+'-clone-'+counter;
                dum = $('div[tag="include"][filename="'+newid+'"]');
            }

            idelm.attr('filename', newid+'.xml');
            var exelm = $('div[tag="exercise"]',cpy).first();
            exelm.attr('id', newid);
            //add/change metadata to indicate this is a clone
            var meta = $('div[tag="metadata"]',cpy);
            if(meta.length===0) {
                meta = $('<div tag="metadata"><div tag="clone" active="true">'+id+'</div></div>')
                exelm.prepend(meta);
            } else {
                var clone = $('div[tag="clone"]',meta);
                if(clone.length===0) {
                    clone = $('<div tag="clone" active="true">'+id+'</div>');
                    meta.prepend(clone);
                } else {
                    clone.attr('active','true');
                    clone.text(id);
                }
            }
            doc.setChanged(true);
            doc.reinit(cpy);
            doc.reinit(base);
        }
    };
});