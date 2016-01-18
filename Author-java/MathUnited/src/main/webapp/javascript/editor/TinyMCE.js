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

define(['jquery','tinymce','mathjax'], function($,__tce, MathJax) {
    var paragraph_id_counter = 0;
    var instances = {};

    var allowedTags = {
        am: true,
        text: true,
        br: true,
        table: true,
        tr: true,
        td: true,
        quotation: true,
        mark: true,
        sup: true,
        textref: true,
        sheetref: true,
        ol: true,
        ul: true,
        li: true,
        p: true,
        'author-remark': true,
        keyword: true,
        word: true,
        cloze: true,
        'cloze-answers': true,
        'cloze-answer': true,
        'cloze-hint': true,
        'cloze-correction': true,
        'cloze-answertext': true
    };

    function allowEditing(par) {
        var allowed = true;
        function m4a_check(elm){
            var tagname = elm.attr('tag');
            if(tagname.substr(0,2)==='m:') {

            } else if (tagname in allowedTags) {
                var v = allowedTags[tagname];
                if (v !== true && v(elm) === false){
                    allowed = false;
                    console.log("Unsupported tag: "+tagname);
                    return false;
                }
            } else {
                allowed = false;
                console.log("Unsupported tag: "+tagname);
                return false;
            }
            return true;
        }
        $('div[tag]',par).each(function(){
            m4a_check($(this));
        });
        $('span[tag]',par).each(function(){
            m4a_check($(this));
        });
        return allowed;
    }
    
    function onBeforeSetContent(obj) {
        var temp = $('<div>').html(obj.content);

        // replace textrefs
        $('span[tag="textref"]',temp).each(function(){
            var ref = $(this).attr('ref');
            if (!ref) {
                ref = $(this).attr('item');
            }
            var elm = $('<span class="textref" ref="'+ref+'">'+$(this).text()+'</span>');
            $(this).replaceWith(elm);
        });

        // replace sheetrefs
        $('span[tag="sheetref"]',temp).each(function(){
            var ref = $(this).attr('item');
            var elm = $('<span class="sheetref" item="'+ref+'">'+$(this).text()+'</span>');
            $(this).replaceWith(elm);
        });
        
        // replaces each am-container span to the ASCIIMathML code (between backquotes)
        var amContainerElm = $('span.am-container',temp);
        amContainerElm.each(function() {
            var am = $('span[tag="am"]',$(this) ).html();
            $(this).replaceWith("`"+am+"`");
        });
        var mathContainerElm = $('span.math-container',temp);

        // <div tag="m:math"> --> <m:math> etc
        function replaceTagToMathElms(elm) {
            var ch = elm.children('span[tag]');
            ch.each(function() {
               var name = $(this).attr('tag');
               var newElm = $('<'+name+'>'+this.innerHTML+'</'+name+'>');
               replaceTagToMathElms(newElm);
               var html = newElm.html();
               html = html.replace(/</g,'&lt;');
               html = html.replace(/>/g,'&gt;');
               $(this).replaceWith('&lt;'+name+'&gt;'+html+'&lt;/'+name+'&gt;'); 
            });
        }

        mathContainerElm.each(function() {
            $('.MathJax',$(this)).remove();
            $('.MathJax_Preview',$(this)).remove();
            $('script',$(this)).remove();

            replaceTagToMathElms($(this));
            $(this).replaceWith($(this).html());
        });

        obj.content = temp.html();
    }

    function onGetContent(obj) {
        var convert = obj.content.replace(/`([^\n\r`]*)`/g,"<span class='am-container'><span tag='am'>$1</span>`$1`</span>");
        //console.log(convert);
        convert = convert.replace(/\u00a0/g, " "); //replace no-break-space with regular space
        obj.content = convert.replace(/\s+/g,' ').trim();
        
        if(obj.content==='') obj.content="<p></p>";
    }

    function onRemove(editor) {
        //add tag elements for math
        var parent = document.getElementById(editor.target.id);
        $('span[class="textref"]',parent).each(function(){
            $(this).replaceWith($('<span tag="textref" ref="'+$(this).attr('ref')+'">'+$(this).html()+'</div>'));
        });
        $('span[class="sheetref"]',parent).each(function(){
            $(this).replaceWith($('<span tag="sheetref" item="'+$(this).attr('item')+'">'+$(this).html()+'</div>'));
        });
        $('table',parent).each(function() {
           var par = $(this);
           par.attr('tag','table');
           $('tbody',par).attr('tag','tbody');
           $('tr',par).attr('tag','tr');
           $('th',par).attr('tag','th');
           $('td',par).attr('tag','td');
        });
        var txt = parent.innerHTML;

        txt = txt.replace(/&lt;m:([a-zA-Z]*)&gt;/g,"<m:$1>");
        txt = txt.replace(/&lt;\/m:([a-zA-Z]*)&gt;/g,"</m:$1>");
        var i0 = txt.indexOf('<m:math');
        var i1 = 0;
        var resultStr = "";
        while(i0>=0){
            var iend = txt.indexOf('/m:math>',i0)+7;
            if(iend<0) break;
            var s1 = txt.substring(i1,i0);
            var mathStr = txt.substring(i0,iend+1);
            var divStr = mathStr.replace(/<m:([a-zA-Z]*)>/g, "<span tag='m:$1'>");
            divStr = divStr.replace(/<\/m:[a-zA-Z]*>/g, "</span>");
            resultStr=resultStr+s1+" <span class='math-container'>"+divStr+mathStr+"</span> ";
            i1 = iend+1;
            i0 = txt.indexOf('<m:math',i1);
        }
        resultStr = resultStr + txt.substring(i1);

        parent.innerHTML = resultStr;

        MathJax.Hub.Queue(["Typeset",MathJax.Hub,editor.id]);
        $('script',parent).each(function() { //bugfix: a '<' symbol messes up the xml document
           var str = this.text.replace('<','&lt;');
           $(this).text(str);
        });

        //deal with images
        $('img',parent).each(function() {
            var img = $(this);

            // Make it a paperfigure by default (i.e. when no ...figure class has been specified yet
            if (!/figure\b/.test(img.attr('class'))) {
                img.addClass('paperfigure');
            }

            var w = img.width();
            var h = img.height();
            if (w > 0) img.attr('width',''+w);
            if (h > 0) img.attr('height',''+h);
        });
        
        //console.log("onremove: "+parent.innerHTML);
    }    

    //concatenate editable blocks into one
    function insertContent(parent, cnt) {
        var following = parent.nextUntil(':not(p,ul.paragraph,ol.paragraph,table,img)');
        var filtered = $('<div></div>');
        following.each(function(){
            if($(this).attr('editor')==='false') return false;
            filtered.append($(this));
        });
        following = filtered.children();
        $('p,ul.paragraph,ol.paragraph,table,img',parent).attr('_done','true');
        $('p,ul.paragraph,ol.paragraph,table,img',following).attr('_done','true');
        cnt.append(parent[0]);//move this paragraph into the editor paragraph (p.paragraph-content)
        following.attr('_done','true').appendTo(cnt);
    }
    
    //active tinyMCE on the paragraph content (.paragraph-content)
    function createTinyMCE(par) {
       var main = require('app/Main');
       var imagebase = main.getImagebase();
        par.tinymce({
            // Location of TinyMCE script
            script_url : 'javascript/tinymce/tinymce.jquery.js',
            content_css : "javascript/tinymce/content.css",
            external_plugins: {
                moxiemanager: "/moxiemanager/plugin.js", //note: moxiemanager is not part of the war-file, because it contains php
                m4a_keyword: "../tinymce_plugins/m4a_keyword/plugin.js",
                m4a_quotation: "../tinymce_plugins/m4a_quotation/plugin.js",
                m4a_textref: "../tinymce_plugins/m4a_textref/plugin.js",
                m4a_remark: "../tinymce_plugins/m4a_remark/plugin.js",
                m4a_image: "../tinymce_plugins/m4a_image/plugin.js",
                m4a_akit: "../tinymce_plugins/m4a_akit/plugin.js",
                m4a_cloze: "../tinymce_plugins/m4a_cloze/plugin.js"
            },

            setup: function(ed) {
                ed.on('BeforeSetContent', function(e) {
                    onBeforeSetContent(e);
                });          
                ed.on('getContent', function(e) {
                    onGetContent(e);
                });          
                ed.on('remove', function(e) {
                    onRemove(e);
                });          
            },

            // General options
            theme : "modern",
            plugins : "paste,fullscreen, table, link, charmap",
            toolbar: "undo redo | bold italic | numlist bullist outdent indent | link unlink m4a_textref | m4a_keyword m4a_quotation m4a_remark m4a_cloze | m4a_image m4a_akit | charmap",
            moxiemanager_rootpath: '/data/'+imagebase,
            //moxiemanager_path: '/logs',//imagebase+'/',
            relative_urls:false,

            //clean HTML. Not XHTML, we rely on TagSoup on the server to convert to XML
            valid_elements : 
              "@[reset|id|class|style|title|dir<ltr?rtl|lang|xml::lang|onclick|ondblclick|"
              + "onmousedown|onmouseup|onmouseover|onmousemove|onmouseout|onkeypress|"
              + "onkeydown|onkeyup|tag|ref|item],"
            + "a[rel|rev|charset|hreflang|tabindex|accesskey|type|"
              + "name|href|target|title|class|onfocus|onblur],"
            + "b/strong,i/em,strike,u,"
            + "#p,-ol[type|compact],-ul[type|compact],-li,br,img[longdesc|usemap|"
            + "src|border|alt=|title|hspace|vspace|width|height|align|location|paperlocation|paperwidth],-sub,-sup,"
            + "-blockquote,-table[border=0|cellspacing|cellpadding|width|frame|rules|"
            + "height|align|summary|bgcolor|background|bordercolor],-tr[rowspan|width|"
            + "height|align|valign|bgcolor|background|bordercolor],tbody,thead,tfoot,"
            + "#td[colspan|rowspan|width|height|align|valign|bgcolor|background|bordercolor"
            + "|scope|paperwidth],#th[colspan|rowspan|width|height|align|valign|scope|paperwidth],caption,-div,"
            + "-span,-code,-pre,address,-h1,-h2,-h3,-h4,-h5,-h6,hr[size|noshade],-font[face"
            + "|size|color],dd,dl,dt,cite,abbr,acronym,del[datetime|cite],ins[datetime|cite],"
            + "object[classid|width|height|codebase|*],param[name|value|_value],embed[type|width"
            + "|height|src|*],map[name],area[shape|coords|href|alt|target],bdo,"
            + "button,col[align|char|charoff|span|valign|width],colgroup[align|char|charoff|span|"
            + "valign|width],dfn,fieldset,form[action|accept|accept-charset|enctype|method],"
            + "input[accept|alt|checked|disabled|maxlength|name|readonly|size|src|type|value],"
            + "kbd,label[for],legend,noscript,optgroup[label|disabled],option[disabled|label|selected|value],"
            + "q[cite],samp,select[disabled|multiple|name|size],small,"
            + "textarea[cols|rows|disabled|name|readonly],tt,var,big,"
            + "span[*]"
       });
    } 

    return {
        getInstance: function(elm) {
            var p;
            if(elm.hasClass('paragraph-content')) p = elm;
            else p = $('.paragraph-content', elm).first();
            if(p.length===1) {
                var id = parseInt(p.attr('id').replace('p',''));
                return instances[id];
            }
        },
        //close all editors, such that the content is saved to the dom
        closeAll: function() {
            if (typeof tinyMCE !== 'undefined') {
                for (var edId in tinymce.editors){
                    var ed = tinymce.editors[edId];
                    ed.save();
                    tinymce.get(ed.id).remove();
                }
            }
        },
        remove: function(jq_elm) {
            var id = this.getInstance(jq_elm);
            if(id) {
                var ed = tinymce.editors[id];
                ed.save();
                if(ed) tinymce.get(ed.id).remove();
            }
        },
        editor: function(parent) {
            if(parent.parents('.tiny-editor').length>0) return; //already attached to an editor
            if(parent.parents('div[tag="componentcontent"]').length===0) return; //not part of editable content
            if(parent.attr('_done')) return;

            parent.attr('_done','true');
            var editorDiv = $('<div class="tiny-editor"><div class="close-paragraph"></div><div class="paragraph-content"></div></div>');
            parent.before(editorDiv);

            var cnt = $('.paragraph-content',editorDiv);
            insertContent(parent, cnt);
            if(!allowEditing(cnt)) {
                //content contains stuff that is not compatible with editor
                cnt.parent().addClass('noneditable');
            } else {
                //register this editor
                var id = 'p'+paragraph_id_counter;
                cnt.attr('id',id);
                paragraph_id_counter = paragraph_id_counter + 1;
                instances[id]=this;

                $('.close-paragraph',editorDiv).unbind('click').click(function() {
                   $(this).removeClass('active');
                   tinymce.get(id).remove();
                });

                cnt.unbind('click').click(function() {
                    var doc = require("app/Document");
                    doc.setChanged(true);
                    $('.close-paragraph',editorDiv).addClass('active');
                    createTinyMCE($(this));
                });
                
                return {
                    remove: function() {
                       tinymce.get(id).remove();
                    }
                };
            }
            
        }
    };
  }
);



