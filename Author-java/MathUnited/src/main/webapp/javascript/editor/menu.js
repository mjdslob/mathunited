var insertContentItem_typeUrl = 'content-items.xml';
var processItem_url = '/MathUnited/processitem';
var paragraph_id_counter = 0;
var menulistid = 0;
var editoroptionid = 0;
function setContextMenu(jqParent) {
    
    //find all menu-buttons, then trace back to the _editor_context_base. Next, collect all references
    //to menu items (._editor_option). The menu itself will be created below the menu-button.
    //the following default behavior is supported
    // - type="repeat": insert (before), insert (after) and remove
    // - type="optional": add or remove a single item
    // - type="action": call a function
    // an item is defined through a template (indicated by attribute 'template'=<id>) or
    // by a function name that performs the intended action.
    $('.menu-button',jqParent).each(function(){
        if($(this).parents('.hidden-templates').length>0) return; //don't add a menu to the hidden templates
        
        var parent = $(this).parent('.menu-button-div');
        if(parent.length===0)return;
        parent.css('display','block');
        var base = $(this).parents('._editor_context_base').first();
        if(base.length==0) return;
        
        //create the menu. Every menu gets a unique id
        base.attr('num',menulistid);
        var menuid = 'menulist-'+menulistid; menulistid+=1;
        var menulist = $('<div class="contextMenu" id="'+menuid+'"><ul></ul></div>');
        $('.contextMenu',parent).remove(); //remove any pre-existing menu
        parent.append(menulist);
        menulist.css('display','none');
        
        //create the menu items, based on the _editor_option references that are found
        var items = $('._editor_option',base);
        var itemnr = 1;
        $(items).each(function() {
            var elm = $(this);
            var par = elm.parents('._editor_context_base').first();
            if(par.attr('num')!==''+(menulistid-1)) return;//belongs to different base
            var id = elm.attr('id');
            if(!id) {
                id = 'editor-option-'+editoroptionid;
                editoroptionid+=1;
                elm.attr('id',id);
            }
            var templateId = elm.attr('template');
            var templateIdValid = (typeof templateId !== 'undefined' && templateId !== false);
            var templateName = elm.attr('name');
            switch(elm.attr('type')) {
                case 'repeat':
                    var grandparent = base.parents('._editor_context_base').first();
                    if(grandparent.length==0) grandparent=$('div[tag="componentcontent"]').first();
                    var min = elm.attr('min'); if(typeof min === 'undefined') min=0;
                    var max = elm.attr('max'); if(typeof max === 'undefined') max=1000;
                    if(templateIdValid) {
                        var num = $('._editor_option[type="repeat"][template="'+templateId+'"]', grandparent).length;
                        if(num===1 && elm.children().length===0){ //fallback to 'optional' because there is no element yet
                            var cmdstr = "optionalItem('"+id+"','"+templateId+"','add')";
                        } else {
                            var insertBeforeCmdStr = "repeatItem('"+id+"','"+templateId+"','add', 'before')";
                            var insertAfterCmdStr = "repeatItem('"+id+"','"+templateId+"','add','after')";
                        }
                        var removeCmdStr = "repeatItem('"+id+"','"+templateId+"','remove')";
                    } else {
                        var funcStr = elm.attr('function');
                        var num = $('._editor_option[type="repeat"][function="'+funcStr+'"]', grandparent).length;
                        if(num===1 && elm.children().length===0) {
                            var cmdstr = elm.attr('function')+"('"+id+"','add')";
                        } else{
                            var insertBeforeCmdStr = funcStr+"('"+id+"','add','before')";
                            var insertAfterCmdStr = funcStr+"('"+id+"','add','after')";
                        }
                        var removeCmdStr = funcStr+"('"+id+"','remove')";
                    }
                    if(num===1 && elm.children().length===0) {
                        $('ul',menulist).append('<li id="item'+itemnr+'" action="'+cmdstr+'">+ '+templateName+'</li>');
                    } else if(num<max && num>0){
                        $('ul',menulist).append('<li id="item'+itemnr+'" action="'+insertBeforeCmdStr+'">+ '+templateName+' (voor)</li>')
                        itemnr+=1;
                        $('ul',menulist).append('<li id="item'+itemnr+'" action="'+insertAfterCmdStr+'">+ '+templateName+' (na)</li>')
                        itemnr+=1;
                        if(num>min) {
                            $('ul',menulist).append('<li id="item'+itemnr+'" action="'+removeCmdStr+'">- '+templateName+'</li>')
                        }
                    }
                    itemnr+=1;
                    break;
                case 'optional':
                    if(elm.children().length==0) {
                        if(templateIdValid) {
                            var cmdstr = "optionalItem('"+id+"','"+templateId+"','add')";
                        } else {
                            var cmdstr = elm.attr('function')+"('"+id+"','add')";
                        }
                        $('ul',menulist).append('<li id="item'+itemnr+'" action="'+cmdstr+'">+ '+templateName+'</li>');
                    } else {
                        if(templateIdValid) {
                            var cmdstr = "optionalItem('"+id+"','"+templateId+"','remove')";
                        } else {
                            var cmdstr = elm.attr('function')+"('"+id+"','remove')";
                        }
                        $('ul',menulist).append('<li id="item'+itemnr+'" action="'+cmdstr+'">- '+templateName+'</li>');
                    }
                    itemnr+=1;
                    break;
                case 'action':
                    $('ul',menulist).append('<li id="item'+itemnr+'" action="'+elm.attr('function')+"('"+id+"')"+'">  '+templateName+'</li>');
                    itemnr+=1;
                    break;
            }
            
        });
        if(itemnr===1) {
            //no options found. Don't display the button and the menu
            parent.css('display','none');
        } else {
            //call the jquery contextmenu plugin
            $(this).contextMenu(menuid, {
                menuStyle: {
                    width: '150px'
                },
                bindings: {
                   'item1': function(t) {
                       var elm = t; //used in action attribute to reference 'this'
                       var parent = $(t).parents('.menu-button-div').first();
                       var item = $('#item1',parent);
                       eval(item.attr('action'));
                    },
                   'item2': function(t) {
                       var elm = t; //used in action attribute to reference 'this'
                       var parent = $(t).parents('.menu-button-div').first();
                       var item = $('#item2',parent);
                       eval(item.attr('action'));
                    },
                   'item3': function(t) {
                       var elm = t; //used in action attribute to reference 'this'
                       var parent = $(t).parents('.menu-button-div').first();
                       var item = $('#item3',parent);
                       eval(item.attr('action'));
                    },
                   'item4': function(t) {
                       var elm = t; //used in action attribute to reference 'this'
                       var parent = $(t).parents('.menu-button-div').first();
                       var item = $('#item4',parent);
                       eval(item.attr('action'));
                    },
                   'item5': function(t) {
                       var elm = t; //used in action attribute to reference 'this'
                       var parent = $(t).parents('.menu-button-div').first();
                       var item = $('#item5',parent);
                       eval(item.attr('action'));
                    },
                   'item6': function(t) {
                       var elm = t; //used in action attribute to reference 'this'
                       var parent = $(t).parents('.menu-button-div').first();
                       var item = $('#item6',parent);
                       eval(item.attr('action'));
                    },
                   'item7': function(t) {
                       var elm = t; //used in action attribute to reference 'this'
                       var parent = $(t).parents('.menu-button-div').first();
                       var item = $('#item7',parent);
                       eval(item.attr('action'));
                    },
                   'item8': function(t) {
                       var elm = t; //used in action attribute to reference 'this'
                       var parent = $(t).parents('.menu-button-div').first();
                       var item = $('#item8',parent);
                       eval(item.attr('action'));
                    }
                }

            });
        }
    });
}

function optionalItem(id, templateId,action) {
    var elm = document.getElementById(id);
    if(action=='remove') {
        $(elm).empty();
    } else {
        var template = $(document.getElementById(templateId)).children('div').clone();
        $(elm).prepend(template);
        insertActions(elm);
    }
    var parent = $(elm).parents('._editor_context_base').first();
    isDocChanged = true;
    setContextMenu(parent);
}
function repeatItem(id, templateId,action, location) {
    var elm = document.getElementById(id);
    var base = $(elm).parents('._editor_context_base').first();
    if(action==='remove') {
        $(elm).empty();
    } else  {
        var template = $(document.getElementById(templateId)).children('div').clone();
        if(location==='after') {
            base.after(template);
        } else {
            base.before(template);
        }
    }
    var parent = base.parents('._editor_context_base').first();
    isDocChanged = true;
    insertActions(parent);
    setContextMenu(parent);
}

//add a single item to a multi-item-exercise

function repeatClosedExerciseItem(id, action, location) {
    repeatExerciseItem(id, action, location, 'exercise-item-closed-template');
}

function repeatExerciseItem(id, action, location, template) {
    var itemLabels = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'];
    if(!template) template='exercise-item-open-template';
    var elm = document.getElementById(id);
    if(!elm) {
        alert('program error');
        return;
    }
    elm = $(elm);
    var parent = elm.parents('div[tag="items"]');
    if(action=='remove') {
        $( "#dialog-remove-item-confirm" ).dialog({
        resizable: false,
        height:140,
        width:400,
        modal: true,
        buttons: {
            "verwijderen": function() {
                elm.remove();
                $('div[tag="item"]',parent).each(function(index,value) {
                    $(this).attr('label',itemLabels[index]);
                    $('.item-label',this).html(itemLabels[index]);
                });
                $( this ).dialog( "close" );
            },
            Cancel: function() {
                $( this ).dialog( "close" );
            }
        }
        });    
    } else {
        var base = elm.parents('._editor_context_base').first();
        if(location=='after'){
            var option = base.after( $('<div class="_editor_context_base"><div class="_editor_option"></div></div>') );
            var newElm = base.next();
        } else {
            var option = base.before( $('<div class="_editor_context_base"><div class="_editor_option"></div></div>') );
            var newElm = base.prev();
        }
        option = $('._editor_option', newElm);
        var attributes = elm.prop("attributes");
        $.each(attributes, function() {
            if(this.name!='id'){
                option.attr(this.name, this.value);
            }
        });

        option.append( $('#'+template).html() );
        $('div[tag="item"]',parent).each(function(index,value) {
            $(this).attr('label',itemLabels[index]);
            $('.item-label',this).html(itemLabels[index]);
        });
        insertActions(newElm);
        setContextMenu(newElm);
    }
    isDocChanged = true;
}

function shiftItemUp(id) {
    var elm = $('#'+id);
    var parent = elm.parents('.item-container').first();
    var _num = -2+parseInt(parent.attr('num'));
    var nextLoc = $('#item-container-'+_num);
    if(nextLoc.parents('.item-container').length>0) {
        nextLoc = nextLoc.parents('.item-container').first();
    }
    parent.insertAfter(nextLoc);
    labelAnchors();
    isDocChanged = true;
}

function shiftItemDown(id) {
    var elm = $('#'+id);
    var parent = elm.parents('.item-container').first();
    var _num = 1+parseInt(parent.attr('num'));
    var nextLoc = $('#item-container-'+_num);
    if(nextLoc.parents('.item-container').length>0) {
        nextLoc = nextLoc.parents('.item-container').first();
    }
    parent.insertAfter(nextLoc);
    labelAnchors();
    isDocChanged = true;
}

function insertContentItem(id) {
    var elm = $('#'+id); //div._editor_option element
    var parent = elm.parents('.item-container').first();
    var contentType = elm.attr('item');
    getContentItem(contentType, function(html) {
        if(parent.length>0) {
            parent.after( $(html) );
        } else {
            parent = elm.parents(".m4a-editor-item-content").first();
            parent.append( $(html) );
        }
    });
    isDocChanged = true;
}
    
function repeatExercise(id, action, location) {
    var elm = $('#'+id); //div._editor_option element
    var base = elm.parents('._editor_context_base').first();
    var parent = elm.parents('.item-container',base).first();
    if(parent.hasClass('shift-item-anchor')) {
        //does not contain an exercise, but is a reference point before any exercises in the containing element
    }
    if(action==='add') {
        var contentType = 'exercises';
        getContentItem(contentType, function(html) {
            if(!location) {
                elm.replaceWith( $(html)); 
            }
            else if(location==='before'){
                base.before( $(html) );
            } else {
                base.after( $(html) );
            }
            var uberBase = base.parents('._editor_context_base').first();
            insertActions(uberBase);
            setContextMenu(uberBase);
            labelAnchors();
        });
    } else {
        $( "#dialog-remove-item-confirm" ).dialog({
            resizable: false,
            height:140,
            width:400,
            modal: true,
            buttons: {
                Cancel: function() {
                    $( this ).dialog( "close" );
                },
                "verwijderen": function() {
                    base.remove();
                }
            }
        });
    }
    isDocChanged = true;
}

//show the frame with metadata for an exercise and set the input elements to the correct values.
//also adds the onchange handler that sets the metadata after the user makes a change.
function setExerciseMetadata(id) {
    var elm = $('#'+id); //div._editor_option element
    var base = elm.parents('._editor_context_base').first();
    var container = $('.metadata-container',base).first().addClass('visible');
    var tag = $('*[tag="metadata"]',container).first();
    var level = $('div[tag="level"]',container).attr('value');
    var is_examenvraag = $('div[tag="exercise-type"][value="examen"]',container).length>0;
    var is_olympiadevraag = $('div[tag="exercise-type"][value="olympiade"]',container).length>0;
    var is_wdavraag = $('div[tag="exercise-type"][value="wda"]',container).length>0;
    $('form input[name="examenvraag"]', container)[0].checked = is_examenvraag;
    $('form input[name="olympiadevraag"]', container)[0].checked = is_olympiadevraag;
    $('form input[name="wda"]', container)[0].checked = is_wdavraag;
    var grouplabels='';
    $('div[tag="group-label"]',container).each(function() {
       grouplabels += $(this).attr('value')+' '; 
    });
    $('form input[name="groepslabel"]', container).val(grouplabels);
    var parRef = $('div[tag="paragraph-ref"]',container).attr('value');
    $('form input[name="ref-id"]', container).val(parRef);
    
    if(level) {
        var dum=$('form input[name="level"][value="'+level+'"]', container);
        if(dum.length>0) dum[0].checked= true;
    };
    var isClone = $('div[tag="clone"]',container).attr('active');
    if(isClone==='true') {
        var dum=$('form input[name="kloonopgave"]', container);
        if(dum.length>0) dum[0].checked= true;
    };
    
    function addMetadataElm(parent, tag, attr, textContent, doReplace) {
        var elm = $('div[tag="'+tag+'"]',parent);
        if(!doReplace || elm.length===0){
            elm = $('<div tag="'+tag+'"></div>');
            parent.append(elm);
        }
        if(attr) {
            for(var name in attr) {
                elm.attr(name, attr[name]);
            }
        }
        if(textContent) elm.text(textContent);
    }
    
    $('form input',container).change(function(data) {
        isDocChanged = true;
        var form = $(data.target).parents('form').first();
        var level = null;
        var isClone = false;
        var cloneElm = $('input[name="kloonopgave"]',container);
        if(cloneElm.length>0) {
            isClone = cloneElm[0].checked;
        }
        $('input[name="level"]',container).each(function() {
           if(this.checked) level = this.value; 
        });
        $('div[tag="exercise-type"]',tag).remove();
        var elm = $('input[name="olympiadevraag"]',container);
        if(elm.length>0 && elm[0].checked) {
            addMetadataElm(tag,'exercise-type', {value: 'olympiade'},null,false);
        }
        var elm = $('input[name="examenvraag"]',container);
        if(elm.length>0 && elm[0].checked) {
            addMetadataElm(tag,'exercise-type', {value: 'examen'},null,false);
        }
        var elm = $('input[name="wda"]',container);
        if(elm.length>0 && elm[0].checked) {
            addMetadataElm(tag,'exercise-type', {value: 'wda'},null,false);
        }
        
        $('div[tag="group-label"]',tag).remove();
        var label = $('input[name="groepslabel"]',container);
        if(label.length>0) {
            var txt = label[0].value;
            var txt = txt.replace('/\s{2,}/g',' ');
            var elms = txt.split(' ');
            for(var ii=0;ii<elms.length;ii++) {
                if(elms[ii].trim().length>0)
                   addMetadataElm(tag, 'group-label',{value: elms[ii]}, null, false);
            }
        }
        if(level) addMetadataElm(tag, 'level',{value: level},null,true);
        addMetadataElm(tag, 'clone',{active: isClone}, null,true);
        var parRef = $('input[name="ref-id"]',container)[0].value;
        addMetadataElm(tag, 'paragraph-ref',{value: parRef}, null,true);
    }); 
}
function closeMetadata(elm) {
    $(elm).parents(".metadata-container").first().removeClass('visible');
}

//opens a dialog containing a list of elements that the user can choose from. 
function getContentItem(itemtype, callback) {
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

function removeContentItem(id) {
    var elm = $('#'+id);
    var parent = elm.parents('.item-container').first();
    $( "#dialog-remove-item-confirm" ).dialog({
        resizable: false,
        height:140,
        width:400,
        modal: true,
        buttons: {
            Cancel: function() {
                $( this ).dialog( "close" );
            },
            "verwijderen": function() {
                parent.remove();
                labelAnchors();
                isDocChanged = true;
                $( this ).dialog( "close" );
            }
        }
    });
}


function optionalContentItem(id, action) {
    var elm = $('#'+id); //div._editor_option element
    var contentType = elm.attr('item');
    if(action==='add'){
        getContentItem(contentType, function(html) {
            elm.append($(html));
            elm.next('.m4a-editor-item.nonexistent').toggleClass('visible');
            insertActions(elm);
            setContextMenu(elm);
            labelAnchors();
            isDocChanged = true;
        });
    }
    if(action==='remove') {
        $( "#dialog-remove-item-confirm" ).dialog({
            resizable: false,
            height:140,
            width:400,
            modal: true,
            buttons: {
                Cancel: function() {
                    $( this ).dialog( "close" );
                },
                "verwijderen": function() {
                    elm.html('');
                    elm.next('.m4a-editor-item.nonexistent').toggleClass('visible');
                    insertActions(elm);
                    setContextMenu(elm);
                    insertActions(elm.next('.m4a-editor-item.nonexistent'));
                    setContextMenu(elm.next('.m4a-editor-item.nonexistent'));
                    labelAnchors();
                    isDocChanged = true;
                    $( this ).dialog( "close" );
                }
            }
        });
    }
}

function createCloneExercise(id) {
    var elm = $('#'+id); //div._editor_option element
    var base = elm.parents('._editor_context_base').first();
    var parent = elm.parents('.item-container',base).first();
    //remove editors first (we cannot copy tinymce, because id's need to be unique)
    $('div.tiny-editor',parent).each(function() {
        var thisElm = $(this);
        var par = $('p', thisElm);
        thisElm.replaceWith(par);
    });
    $('._editor_context_base',parent).removeAttr('num');
    $('.contextMenu',parent).remove();
    $('._editor_option').removeAttr('id');
    var cpy = parent.clone();
    var container = $('<div class="exercise-container" clone="true"></div>');
    container.append(cpy);
    parent.after(container);
    //change id's
    var idelm = $('div[tag="include"]',cpy).first();
    var id = idelm.attr('filename').replace('.xml','');
    var counter=1;
    var newid = id+'-clone-'+counter;
    var dum = $('div[tag="include"][filename="'+newid+'"]');
    if(dum.length>0) {
        counter++;
        newid = id+'-clone-'+counter;
        dum = $('div[tag="include"][filename="'+newid+'"]');
    }

    idelm.attr('filename', newid+'.xml');
    var exelm = $('div[tag="exercise"]',cpy).first();
    exelm.attr('id', newid);
    //add/change metadata to indicate this is a clone
    var meta = $('div[tag="metadata"]',cpy);
    if(meta.length===0) {
        meta = $('<div tag="metadata"><div tag="clone" active="true">'+id+'</div></div>')
        exelm.prepend(meta);
    } else {
        var clone = $('div[tag="clone"]',meta);
        if(clone.length===0) {
            clone = $('<div tag="clone" active="true">'+id+'</div>');
            meta.prepend(clone);
        } else {
            clone.attr('active','true');
            clone.text(id);
        }
    }
    isDocChanged = true;
    insertActions(cpy);
    setContextMenu(cpy);
    insertActions(base);
    setContextMenu(base);
    labelAnchors();
    
}
