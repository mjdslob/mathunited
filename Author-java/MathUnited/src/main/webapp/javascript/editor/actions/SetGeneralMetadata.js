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
            var doc = require('app/Document');
            //search up from the activated menu-button to the root of the 'context' it is part of
            var base = elm.parents('._editor_context_base').first();
            
            //container contains both the visual frame as the div with xml-tags
            var container = $('.metadata-container',base).first().addClass('visible');
            //tag contains the xml-tags : not visible but defines what is stored as xml
            var tag = $('*[tag="metadata"]',container).first();

            //medium: web, paper, both or none. Not set in metadata, but as attribute on item
            var item = container.parents('div.included-item-wrapper').first();
            if(item.length>0){
                var medium = item.attr('medium');
                if(!medium) medium='both';
                var dum=$('form input[name="medium"][value="'+medium+'"]', container);
                if(dum.length>0) dum[0].checked= true;
            } else {
                $('.meta-medium',container).css('display','none');
            }

            //close button
            $('.close-metadata-button',container).click(function(){
                 $(this).parents(".metadata-container").first().removeClass('visible');
            });

            $('form input',container).change(function(data) {
                $('input[name="medium"]',container).each(function() {
                   if(this.checked) medium = this.value; 
                });
                item.attr('medium', medium);
                var includeElm = container.parents('div[tag="include"]').first();
                var itemElm = $('div[tag]',includeElm).first();
                itemElm.attr('medium',medium);
                //container.parents('div[tag="example"]').first().attr('medium',medium);
                var txt;
                switch(medium) {
                    case 'web': txt='web'; break;
                    case 'paper': txt='papier'; break;
                    case 'none': txt='verborgen'; break;
                    default: txt='';
                }
                $('div.block-button',item).first().text(txt);
                 
            });

            doc.labelAnchors();
            doc.setChanged(true);
        }
    };
});