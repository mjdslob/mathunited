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
            var parent = elm.parents('.item-container').first();
            var _num = 1+parseInt(parent.attr('num'));
            var nextLoc = $('#item-container-'+_num);
            if(nextLoc.parents('.item-container').length>0) {
                nextLoc = nextLoc.parents('.item-container').first();
            }
            parent.insertAfter(nextLoc);
            doc.labelAnchors();
            doc.setChanged(true);
        }
    };
});