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
    
    
    var objelm = $('div[tag="description"] div[tag="objectives"]').first();
    
    function removeObjectiveHandler() {
        var par = $(this).parents('div[tag="description"] div[tag="objective"]').first();
        var id = par.attr('id');
        var metaHandler = require('actions/SetExerciseMetadata');
        metaHandler.removeObjectiveFromDocument(id);
        par.remove();
    }
    
    $('div.objective-add-button',objelm).first().click(function() {
        var par = $(this).parents('.objective-new-item').first();
        var num=1;
        while( $('#obj-'+num).length>0) num++;
        
        var id = 'obj-'+num;
        var descr = $('input',par).val();
        if(descr!==null && descr.length>0) {
            var elm = $('<div tag="objective" id="'+id+'">'+descr
             +'<div class="objective-remove-button"/><div style="clear:both"/></div>');
            par.before(elm);
            $('input',par).val('');
            $('.objective-remove-button',elm).click(removeObjectiveHandler);
        }
        doc.setChanged(true);
    });
    $('div.objective-remove-button',objelm).click(removeObjectiveHandler);
    
    
    return {
        action : function() {
            
        }
    };
});