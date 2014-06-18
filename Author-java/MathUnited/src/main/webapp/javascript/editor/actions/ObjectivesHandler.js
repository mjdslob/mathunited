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

define(['jquery','app/Document'], function($, doc) {
    var LOADOBJECTIVES_URL = "/MathUnited/getobjectives";
    
    var objelm = $('div[tag="description"] div[tag="objectives"]').first();
    
    function removeObjectiveHandler() {
        var par = $(this).parents('div[tag="description"] div.objective-wrapper').first();
        var tag = $('div[tag="objective"]',par);
        var id = tag.attr('id');
        var metaHandler = require('actions/SetExerciseMetadata');
        metaHandler.removeObjectiveFromDocument(id);
        par.remove();
        doc.setChanged(true);
    }
    function changedHandler() {
        var txt = $(this).val();
        var par = $(this).parents('div.objective-wrapper').first();
        var tag = $('div[tag="objective"]',par);
        tag.text(txt);
        
        //also change text in metadata of exercises in current page
        $('.metadata-obj-selector-container input[value="'+tag.attr('id')+'"]')
                .next('.objective-ref-text').text(txt);
        doc.setChanged(true);
    }
    
    // voor Totaalbeeld: haal alle leerdoelen op van de andere paragrafen
    function loadObjectivesFromServer(parent_jq) {
        var main = require('app/Main');
        $.get(LOADOBJECTIVES_URL, {
            comp: main.getComp()
        }, function(data) {
            $('objective', $(data)).each(function(){
                var elm = $(this);
                parent_jq.append('<div class="objective" id="'+elm.attr('id')+'" comp="'+elm.attr('comp')
                        +'" subcomp="'+elm.attr('subcomp')+'">par. '+elm.attr('subcomp')+': '+elm.text()+'</div>');
            });
        });
    }

    $('div.objective-add-button',objelm).first().click(function() {
        var par = $(this).parents('.objective-new-item').first();
        var num=1;
        while( $('#obj-'+num).length>0) num++;
        
        var id = 'obj-'+num;
        var descr = $('input',par).val();
        if(descr!==null && descr.length>0) {
            var elm = $(//note: this html fragment must be consistent with xslt (m4a_editor.xslt)
                    '<div class="objective-wrapper">'
                   +  '<input class="objective-input" type="text" value="'+descr+'"></input>'
                   +  '<div tag="objective" id="'+id+'">'+descr+'</div>'
                   +  '<div class="objective-remove-button"/><div style="clear:both"/>'
                   +'</div>');
            par.before(elm);
            $('input',par).val('');
            $('.objective-remove-button',elm).click(removeObjectiveHandler);
            $('input.objective-input',elm).change(changedHandler);
        }
        doc.setChanged(true);
    });
    
    $('div.objective-remove-button',objelm).click(removeObjectiveHandler);
    $('div.objective-wrapper input.objective-input',objelm).change(changedHandler);
    
    return {
        init: function() {
            var elm = $('.load-objectives');
            if(elm.length>0) {
                loadObjectivesFromServer(elm);
            }
        },
        action : function() {
            
        }
    };
});