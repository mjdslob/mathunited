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
    
    
    var objelm = $('div[tag="objectives"]').first();
    
    function removeObjectiveHandler() {
        var par = $(this).parents('div[tag="objective"]').first();
        par.remove();
    }
    
    $('div.objective-add-button',objelm).first().click(function() {
        var par = $(this).parents('.objective-new-item').first();
        var id = $('.objective-id input',par).val();
        var descr = $('.objective-description input',par).val();
        if(id!==null && descr!==null && id.length>0 && descr.length>0) {
            var elm = $('<div tag="objective"><div class="objective-id">'+id+'</div>'
             +'<div class="objective-description">'+descr+'</div>'
             +'<div class="objective-remove-button"/><div style="clear:both"/></div>');
            par.before(elm);
            $('.objective-id input',par).val('');
            $('.objective-description input',par).val('');
            $('.objective-remove-button',elm).click(removeObjectiveHandler);
        }
    });
    $('div.objective-remove-button',objelm).click(removeObjectiveHandler);
    
    
    return {
        action : function() {
            
        }
    };
});