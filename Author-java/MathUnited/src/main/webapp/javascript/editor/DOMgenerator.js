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
    var insertContentItem_typeUrl = 'content-items.xml';
    var processItem_url = '/MathUnited/processitem';

    function xmlToString(xmlData) { 

        var xmlString;
        //IE
        if (window.ActiveXObject){
            xmlString = xmlData.xml;
        }
        // code for Mozilla, Firefox, Opera, etc.
        else{
            xmlString = (new XMLSerializer()).serializeToString(xmlData[0]);
        }
        return xmlString;
    }   
    
    return {
        //opens a dialog containing a list of elements that the user can choose from. 
        getContentItem: function(itemtype, callback) {
            $.get(insertContentItem_typeUrl, '', function(xml) {
                var container = $('container[name="'+itemtype+'"]',xml);
                var html='<div>';
                var num=0;
                $('container-item',container).each(function(){
                   html = html+'<div class="item-type" num="'+num+'">'+$(this).attr('name')+'</div>'; 
                   $(this).attr('num',num);
                   num++;
                });
                html=html+"</div>";
                var dlg = $(html);
                dlg.dialog({
                    resizable: true,
                    width:400,
                    modal: true,
                    buttons: {
                        Cancel: function() {
                            $( this ).dialog( "close" );
                        }
                    }
                });    

                //transform the selected item from xml to html, using the same xslt stylesheet as is used by the editor
                $('.item-type',dlg).click(function() {
                    var cnt = $('container-item[num="'+$(this).attr('num')+'"]',container);
                    var xmlstr = xmlToString(cnt.children().first());
                    var subcomp = $('#meta-data-subcomp').text();
                    $.post(processItem_url, {
                        comp: $('#meta-data-comp').text(),
                        subcomp: subcomp,
                        variant: $('#meta-data-variant').text(),
                        xml:xmlstr
                    }, function(htmlStr) {
                        //process ids: __subcomp__ refers to the subcomponent. 
                        //__#?__ referes to a (unique) number. First __#1__ is resolved, then __#2__, etc
                        htmlStr = htmlStr.replace(/__subcomp__/g,subcomp);
                        var idnum = 1;
                        var goOn = true;

                        while(goOn) {
                            goOn = false;
                            var cnt = $(htmlStr);
                            $('div[tag="include"]',cnt).each(function(){
                                var fname = $(this).attr('filename');
                                var refstr = fname.match('__#'+idnum+'__');
                                if(refstr && refstr.length>0) {
                                    refstr = refstr[0];
                                    var counter=1;
                                    var newid = fname.replace(refstr,counter);
                                    //check if this new id is unique. If not, increase counter
                                    var elm = $('div[tag="include"][filename="'+newid+'"]');
                                    while(elm.length>0) {
                                        counter++;
                                        newid = fname.replace(refstr,counter);
                                        elm = $('div[tag="include"][filename="'+newid+'"]');
                                    }
                                    //replace all occurences:
                                    var patt= new RegExp(refstr,'g');
                                    htmlStr = htmlStr.replace(patt,counter);
                                    goOn = true;
                                }
                            });
                            idnum++;
                        }

                        callback(htmlStr);
                        dlg.dialog("close");
                    });
                });

            });
        }
        
    };
});