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
            var templateId = params.template;
            var action = params.cmd;
            var doc = requires('app/Document');

            if(action==='remove') {
                elm.empty();
            } else {
                var template = $(document.getElementById(templateId)).children('div').clone();
                elm.prepend(template);
            }
            var parent = elm.parents('._editor_context_base').first();
            doc.reinit(parent);
            doc.setChanged(true);
        }
    };
});