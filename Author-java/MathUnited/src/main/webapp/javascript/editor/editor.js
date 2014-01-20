var commitURL = '/MathUnited/postcontent';

function onBeforeSetContent(obj) {
    var temp = $('<div>').html(obj.content);
    
    //replace textrefs
    $('span[tag="textref"]',temp).each(function(){
        var ref=$(this).attr('ref');
        if(!ref) ref=$(this).attr('item');
        var elm = $('<span class="textref" ref="'+ref+'">'+$(this).text()+'</span>');
        $(this).replaceWith(elm);
    });
    //replaces each am-container span to the ASCIIMathML code (between backquotes)
    var amContainerElm = $('span.am-container',temp);
    amContainerElm.each(function() {
        var am = $('span[tag="am"]',this).text();
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
        $('script',$(this)).remove();
        
        replaceTagToMathElms($(this));
        $(this).replaceWith($(this).html());
    });

    obj.content = temp.html();
}

function onGetContent(obj) {
    obj.content = obj.content.replace(/\s+/g,' ');
    obj.content = obj.content.replace(/`([^`]*)`/g,"<span class='am-container'><span tag='am'>$1</span>`$1`</span>")
    if(obj.content=='') obj.content="<p></p>";
/*    
    obj.content = "";
    var i0 = txt.indexOf('&lt;m:math');
    var i1 = 0;
    while(i0>=0){
        var iend = txt.indexOf('/m:math&gt;',i0)+10;
        if(iend<0) break;
        var s1 = txt.substring(i1,i0);
        var snew = txt.substring(i0,iend+1);
        snew = snew.replace(/&lt;/g,'<');
        snew = snew.replace(/&gt;/g,'>');
        obj.content=obj.content+s1+snew;
        i1 = iend+1;
        i0 = txt.indexOf('&lt;m:math',i1);
    }
    obj.content = obj.content + txt.substring(i1);
*/    
}

function onRemove(editor) {
    //add tag elements for math
    var parent = document.getElementById(editor.target.id);
    $('span[class="textref"]',parent).each(function(){
        $(this).replaceWith($('<span tag="textref" ref="'+$(this).attr('ref')+'">'+$(this).html()+'</div>'));
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
    //deal with images
    $('img',parent).each(function() {
        var img = $(this);
        img.addClass('paperfigure');
        
        var w = img.width();
        var h = img.height();
        img.attr('WIDTH',''+w);
        img.attr('HEIGHT',''+h);
    });

}
var allowedTags = {
    am:true,
    text:true,
    br:true,
    table:true,
    tr:true,
    td:true,
    quotation:true,
    sup:true,
    textref:true,
    ol:true,
    ul:true,
    li:true,
    p:true,
    'author-remark':true,
    keyword: function(elm) {
                 var child = $(elm).children(); 
                 if(child.length>1)return false; 
                 if(child.attr('tag')!=='text') return false; 
                 return true;
             }
    
};
function allowEditing(par) {
    var allowed = true;
    function m4a_check(elm){
        var tagname = elm.attr('tag');
        if(tagname.substr(0,2)=='m:') {
            
        } else if(tagname in allowedTags) {
            var v = allowedTags[tagname];
            if(v!==true && v(elm)===false)
                allowed = false;
                return false;
        } else {
            allowed = false;
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

$(document).ready(function() {
    //check if images exist, if not fallback to backup repository
    var baseRepo = $('#meta-data-baserepo-path').text();
    var repo= $('#meta-data-repo-path').text();
    if(baseRepo.length>0){
        $('img').each(function() {
            var img = $(this);
            if(img[0].naturalWidth===0) {
                var src = img[0].src;
                img[0].src = src.replace(repo,baseRepo);
            }
        });
    }
    
    //explicitly set WIDTH and HEIGHT attributes on images for proper usage in tinymce
    $('img').each(function() {
        var img = $(this);
        var w = img.width();
        var h = img.height();
        if(w>0){
            img.attr('WIDTH',''+w);
        }
        if(h>0){
            img.attr('HEIGHT',''+h);
        }
    });

    labelAnchors();
    $('.item-container').each(function() {
        var parent = $(this);
        $('.shift-handle-next',this).click(function() {
            var _num = 1+parseInt(parent.attr('num'));
            var nextLoc = $('#item-container-'+_num);
            if(nextLoc.parents('.item-container').length>0) {
                nextLoc = nextLoc.parents('.item-container').first();
            }
            parent.insertAfter(nextLoc);
            labelAnchors();
        });
        $('.shift-handle-prev',this).click(function() {
            var _num = -2+parseInt(parent.attr('num'));
            var nextLoc = $('#item-container-'+_num);
            if(nextLoc.parents('.item-container').length>0) {
                nextLoc = nextLoc.parents('.item-container').first();
            }
            parent.insertAfter(nextLoc);
            labelAnchors();
        });
        
    });
    insertActions($('div.pageDiv'));
    setContextMenu($('div.pageDiv'));
});

function labelAnchors() {
    var shiftId=0;
    $('.item-container').each(function(){
        $(this).attr('id','item-container-'+shiftId);
        $(this).attr('num',shiftId);
        shiftId++;
    });
}


function insertActions(jqParent) {
    var editorDiv = null;
    $('.m4a-editor-item-container').each(function() {
        var par = $(this);
        $('.m4a-editor-item-title',par).unbind("click").click(function() {
            par.toggleClass('open');
        });
    });
    
    $('p,ul.paragraph,ol.paragraph,img',jqParent).each(function() {
        if($(this).parents('.tiny-editor').length>0) return; //already attached to an editor
        
        if($(this).attr('_done')) {
            return; //already processed in earlier item of this .each()
        } else {
            $(this).attr('_done','true');
            editorDiv = $('<div class="tiny-editor"><div class="close-paragraph"></div><div class="paragraph-content"></div></div>')
            $(this).before(editorDiv);
            //concatenate editable blocks into one
            var cnt = $('.paragraph-content',editorDiv);
            var following = $(this).nextUntil(':not(p,ul.paragraph,ol.paragraph,table,img)');
            var filtered = $('#dummy123');
            following.each(function(){
                if($(this).attr('editor')==='false') return false;
                filtered.add($(this));
            });
            following = filtered;
            $('p,ul.paragraph,ol.paragraph,table,img',$(this)).attr('_done','true');
            $('p,ul.paragraph,ol.paragraph,table,img',following).attr('_done','true');
            cnt.append(this);
            following.attr('_done','true').appendTo(cnt);
        }
    });
    $('*[_done]').removeAttr('_done');
    
    $('.paragraph-content',jqParent).each(function() {
        var curid = $(this).attr('id');
        if(!curid) {
            $(this).attr('id','p'+paragraph_id_counter);
            paragraph_id_counter = paragraph_id_counter + 1;
        }
    });
    $('.close-paragraph',jqParent).unbind('click').click(function() {
       $(this).removeClass('active');
       var par = $('.paragraph-content',$(this).parent());
       tinymce.get(par.attr('id')).remove();
//       tinymce.EditorManager.execCommand('mceRemoveControl',true, par.attr('id'));
       //tinymce.EditorManager.execCommand('mceAddControl',true, editor_id);
    });
    $('.block-button',jqParent).unbind('click').click(function() {
        var par = $(this).parent();
        var cont = $('.block-content',par);
        cont.toggleClass('visible');
        $(this).toggleClass('visible')
    });
    $('.worksheet-button',jqParent).unbind('click').click(function() {
        var par = $(this).parent();
        var cont = $('.worksheet-content',par);
        cont.toggleClass('visible');
        $(this).toggleClass('visible')
    });
    $('.answer-button',jqParent).unbind('click').click(function() {
        var par = $(this).parent();
        var cont = $('.answer-content',par);
        cont.toggleClass('visible');
        $(this).toggleClass('visible')
    });
    var pars = $('.paragraph-content',jqParent);
    pars.each(function() {
       if(!allowEditing(this)) {
           $(this).parent().addClass('noneditable');
       }
    });
    var compbase = '/data/'+$('#meta-data-refbase').text();
    var ind = compbase.lastIndexOf('/'); //2 times, because of trailing /
    compbase = compbase.substr(0,ind);
    var ind = compbase.lastIndexOf('/');
    compbase = compbase.substr(0,ind)+'/images/highres';
    pars.unbind('click').click(function() {
       var parent = $(this).parent();
       if( $(this).parents('.noneditable').length > 0) return true;
       $('.close-paragraph',parent).addClass('active');
       $(this).tinymce({
            // Location of TinyMCE script
            script_url : 'javascript/tinymce/tinymce.jquery.js',
            content_css : "javascript/tinymce/content.css",
            external_plugins: {
                "moxiemanager": "/Publisher/moxiemanager/plugin.js",
                "m4a_keyword": "../tinymce_plugins/m4a_keyword/plugin.js",
                "m4a_quotation":"../tinymce_plugins/m4a_quotation/plugin.js",
                "m4a_textref":"../tinymce_plugins/m4a_textref/plugin.js",
                "m4a_remark":"../tinymce_plugins/m4a_remark/plugin.js",
                "m4a_image":"../tinymce_plugins/m4a_image/plugin.js"
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
            toolbar: "undo redo | bold italic | numlist bullist outdent indent | link unlink m4a_textref | m4a_keyword m4a_quotation m4a_remark | m4a_image | charmap",
            moxiemanager_rootpath: compbase+'/',
            moxiemanager_path: compbase+'/',
            relative_urls:false,
        
        //clean HTML. Not XHTML, we rely on TagSoup on the server to convert to XML
valid_elements : 
  "@[id|class|style|title|dir<ltr?rtl|lang|xml::lang|onclick|ondblclick|"
  + "onmousedown|onmouseup|onmouseover|onmousemove|onmouseout|onkeypress|"
  + "onkeydown|onkeyup|tag|ref],"
+ "a[rel|rev|charset|hreflang|tabindex|accesskey|type|"
  + "name|href|target|title|class|onfocus|onblur],"
+ "b/strong,i/em,strike,u,"
+ "#p,-ol[type|compact],-ul[type|compact],-li,br,img[longdesc|usemap|"
+ "src|border|alt=|title|hspace|vspace|width|height|align|location],-sub,-sup,"
+ "-blockquote,-table[border=0|cellspacing|cellpadding|width|frame|rules|"
+ "height|align|summary|bgcolor|background|bordercolor],-tr[rowspan|width|"
+ "height|align|valign|bgcolor|background|bordercolor],tbody,thead,tfoot,"
+ "#td[colspan|rowspan|width|height|align|valign|bgcolor|background|bordercolor"
+ "|scope],#th[colspan|rowspan|width|height|align|valign|scope],caption,-div,"
+ "-span,-code,-pre,address,-h1,-h2,-h3,-h4,-h5,-h6,hr[size|noshade],-font[face"
+ "|size|color],dd,dl,dt,cite,abbr,acronym,del[datetime|cite],ins[datetime|cite],"
+ "object[classid|width|height|codebase|*],param[name|value|_value],embed[type|width"
+ "|height|src|*],map[name],area[shape|coords|href|alt|target],bdo,"
+ "button,col[align|char|charoff|span|valign|width],colgroup[align|char|charoff|span|"
+ "valign|width],dfn,fieldset,form[action|accept|accept-charset|enctype|method],"
+ "input[accept|alt|checked|disabled|maxlength|name|readonly|size|src|type|value],"
+ "kbd,label[for],legend,noscript,optgroup[label|disabled],option[disabled|label|selected|value],"
+ "q[cite],samp,select[disabled|multiple|name|size],small,"
+ "textarea[cols|rows|disabled|name|readonly],tt,var,big"        
        

       });
    }); 
}

function submitDocument(repo, comp, subcomp) {
    //save all edits in open editors first
    if (typeof tinyMCE !== 'undefined') {
        for (var edId in tinymce.editors){
            var ed = tinymce.editors[edId];
            ed.save();
            tinymce.get(ed.id).remove();
        }
    }
    var html = $('.pageDiv').first().html();
    var str = repo+'\n'+comp+'\n'+subcomp+'\n'+html;
//    html = encodeURIComponent(html);
    $.post(commitURL, str,
        function(data) {//on success
            if($('post',data).attr('result')!="true") {
                var msg = $('post message',data).text();
                alert('Fout bij opslaan van het document: '+msg);
            } else {
                alert('Het document is opgeslagen');
            }
        })
}

