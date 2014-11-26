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

//This is a stub for the actual AlgebraKIT-engine which runs on the server.
define(['jquery'], function($) {
    return {

        //required when copying html containing MathJax 
        normalizeMathJax : function(elm) {
            $('.MathJax_Preview', elm).remove();
            $('.MathJax', elm).remove();

            $('script', elm).each(function() {
                var str = $(this).text();
                if ($(this).attr('type') === 'math/asciimath') {
                    $(this).replaceWith($('<span>`' + str + '`</span>'));
                } else {
                    $(this).replaceWith($('<span>' + str + '</span>'));
                }
            });
        }
    };
  }
);



