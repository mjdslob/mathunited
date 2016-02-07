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

define(['jquery','mathjax'], function($, MathJax) {
    
    $('.metadata-container .close-metadata-button').each(function() {
        
    });
    return {
        action : function(elm, params) {
            var doc = require('app/Document');
            var base = elm.parents('._editor_context_base').first();
            var parent = elm.parents('.item-container',base).first();
            //remove editors first (we cannot copy tinymce, because id's need to be unique)
            var tinymce = require('app/TinyMCE');
            $('div.tiny-editor',parent).each(function() {
                //var thisElm = $(this);
                tinymce.remove($(this));
                /*
                var dest = $(this).parent();
                thisElm.children().appendTo(dest);
                thisElm.remove();
                */
            });
            $('._editor_context_base',parent).removeAttr('num');
            $('.contextMenu',parent).remove();
            $('._editor_option',parent).removeAttr('id');
            var idelm = $('div[tag="include"]',parent).first();
            var id = idelm.attr('filename').replace('.xml','');
            doc.prepareForSubmit(parent);
            var generator = require('app/DOMgenerator');
            //create a copy of the current exercise...
            generator.getXML(parent[0], function(xml) {
                xml = $(xml);

                // Remove uuid
                xml.find('[uuid]').removeAttr('uuid');

                //...and make the necessary adjustments to the xml to make this a clone exercise
                //create a unique id
                var counter=1;
                var newid = id+'-clone-'+counter;
                var dum = $('div[tag="include"][filename="'+newid+'"]');
                while(dum.length>0) {
                    counter++;
                    newid = id+'-clone-'+counter;
                    dum = $('div[tag="include"][filename="'+newid+'"]');
                }
                $('include',xml).first().attr('filename', newid+'.xml');
                $('exercise',xml).first().attr('id', newid);
                if($('metadata',xml).length===0) xml.append('<metadata/>');
                $('metadata clone',xml).remove();
                $('metadata',xml).prepend($('<clone active="true">'+id+'</clone>'));

                generator.convertXML(xml, function(elm) {
                    parent.after(elm);
                    doc.setChanged(true);
                    doc.reinit(elm);
                    doc.reinit(base);
                    MathJax.Hub.Queue(["Typeset",MathJax.Hub,elm[0]]);

                });
            });

//            var container = $('<div class="exercise-container" clone="true"></div>');
        }
    };
});