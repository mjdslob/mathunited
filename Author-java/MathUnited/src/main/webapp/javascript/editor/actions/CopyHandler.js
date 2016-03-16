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

//copy an item to the clipboard. The clipboard is maintained on the server. 
//the item is transformed into xml and saved into the clipboard
define(['jquery','app/Document','app/DOMgenerator'], function($, doc,generator) {
    var saveToClipboard_url = '/MathUnited/copy-to-clipboard';
    
    return {
        action : function(elm, params) {
            //transform html into xml
            var base = elm.parents('._editor_context_base').first();
            var parent = elm.parents('.item-container',base).first();
            //var parent = base;
            var type = params.itemtype;
            generator.getXML(parent[0], function(xml) {
                xml = $(xml);

                // Remove uuid attributes
                xml.find('[uuid]').removeAttr('uuid');

                //modify ids
                //newid = <id>-copy1.xml
                $('include',xml).each(function() {
                    var fname = $(this).attr('filename');
                    //remove .xml and optional -copy<num> if this id is already the result of a previous copy
                    var fnamebase = fname.replace(/(-copy\d*)?\.xml$/,'');
                    var num = 1;
                    var newfname = fnamebase+'-copy'+num+'.xml';
                    var elm = $('div[tag="include"][filename="' + newfname + '"]');
                    while(elm.length>0) {
                        num++;
                        newfname = fnamebase+'-copy'+num+'.xml';
                        elm = $('div[tag="include"][filename="' + newfname + '"]');
                    }
                    $(this).attr('filename',newfname);
                });
                //send xml to server
                var xmlstr = generator.xmlToString(xml);
                $.post(saveToClipboard_url, {
                    xml:xmlstr,
                    type: type
                }, function(response) {
                    //handle response here...
                });            
            });        
        }
    };
});