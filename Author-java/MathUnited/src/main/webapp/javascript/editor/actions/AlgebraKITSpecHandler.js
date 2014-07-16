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
        init: function() {            
            $('.algebrakit-spec-wrapper').each(function() {
                var parent = $(this);
                var tag = $('div[tag="evaluation"]', parent);
                $('input', parent).change(function() {
                    var elm = $(this);
                    var name = elm.attr('name');
                    tag.attr(name, elm.val());
                });
                
                var sel = $('select.audience-select',parent);
                var aud = tag.attr('audience');
                sel.val(aud);
                sel.change(function() {
                   var option = $('option:selected',$(this));
                   var value = option.attr('value');
                   tag.attr('audience',value);
                });
            });
            
        },
        action : function(elm, params) {  }
    };
});