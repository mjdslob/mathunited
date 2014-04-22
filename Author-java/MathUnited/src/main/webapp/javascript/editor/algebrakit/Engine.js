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
//    var engineUrl = 'http://mathunited.pragma-ade.nl:41080/AKIT_RemoteServer/Main';
//    var engineUrl = 'http://localhost/AKIT_RemoteServer/Main';
    var engineUrl = '/AKIT_RemoteServer/Main';
    
    return {

        solve: function(expression, audience, callback) {
            var params = 'cmd=solve&exp='+encodeURIComponent(expression)+'&audience='+audience;
            $.post(engineUrl, params, 
                   function(data) {
                        data = JSON.parse(data);
                        callback(data);
                   }
            );
        }
        
    };
  }
);



