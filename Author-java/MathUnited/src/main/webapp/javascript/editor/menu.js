var insertContentItem_typeUrl = 'content-items.html';
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
            if(par.attr('num')!==''+(menulistid-1)) return;
            var id = 'editor-option-'+editoroptionid;
            editoroptionid+=1;
            elm.attr('id',id);
            var templateId = elm.attr('template');
            var templateIdValid = (typeof templateId !== 'undefined' && templateId !== false);
            var templateName = elm.attr('name');
            switch(elm.attr('type')) {
                case 'repeat':
                    var min = elm.attr('min'); if(typeof min === 'undefined') min=0;
                    var max = elm.attr('max'); if(typeof max === 'undefined') max=1000;
                    if(templateIdValid) {
                        var insertBeforeCmdStr = "repeatItem('"+id+"','"+templateId+"','add', 'before')";
                        var insertAfterCmdStr = "repeatItem('"+id+"','"+templateId+",'add','after')";
                        var removeCmdStr = "repeatItem('"+id+"','"+templateId+"','remove')";
                        var num = items.filter('[type="repeat"][template="'+templateId+'"]').length;
                    } else {
                        var funcStr = elm.attr('function');
                        var num = items.filter('[type="repeat"][function="'+funcStr+'"]').length;
                        var insertBeforeCmdStr = funcStr+"('"+id+"','add','before')";
                        var insertAfterCmdStr = funcStr+"('"+id+"','add','after')";
                        var removeCmdStr = funcStr+"('"+id+"','remove')";
                    }
                    if(num<max){
                        $('ul',menulist).append('<li id="item'+itemnr+'" action="'+insertBeforeCmdStr+'">+ '+templateName+' (voor)</li>')
                        itemnr+=1;
                        $('ul',menulist).append('<li id="item'+itemnr+'" action="'+insertAfterCmdStr+'">+ '+templateName+' (na)</li>')
                        itemnr+=1;
                    }
                    if(num>min) {
                        $('ul',menulist).append('<li id="item'+itemnr+'" action="'+removeCmdStr+'">- '+templateName+'</li>')
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
    setContextMenu(parent);
}

//add a single item to a multi-item-exercise
function repeatExerciseItem(id, action, location) {
    var itemLabels = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'];
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

        option.append( $('#exercise-item-open-template ').html() );
        $('div[tag="item"]',parent).each(function(index,value) {
            $(this).attr('label',itemLabels[index]);
            $('.item-label',this).html(itemLabels[index]);
        });
        insertActions(newElm);
        setContextMenu(newElm);
    }
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
}

function insertContentItem(id) {
    var elm = $('#'+id);
    var parent = elm.parents('.item-container').first();
    var contentType = parent.attr('type');
    $.get(insertContentItem_typeUrl, '', function(xml) {
        var itemParent = $('.itemClass.'+contentType,xml);
        var html='<div>';
        var num=0;
        $('.itemType',itemParent).each(function(){
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
        $('.item-type',dlg).click(function() {
            var cnt = $('.itemType[num="'+$(this).attr('num')+'"]',itemParent);
            var newElm = $('<div class="item-container"></div>');
            parent.after(newElm);
            cnt.children().first().appendTo(newElm);
            $('div[tag="include"]',newElm).each(function(){
                debugger;
                var par = $(this).parents('div[tag="include"]').first();
                var curid = contentType+'.xml';
                if(par.length>0) {
                    var curid = par.attr('filename');
                }
                var counter = 1;
                var newid = curid.replace('.xml','-'+counter+'.xml');
                var elm = $('div[tag="include"][filename="'+newid+'"]');
                while(elm.length>0) {
                    counter++;
                    newid = curid.replace('.xml','-'+counter+'.xml');
                    elm = $('div[tag="include"][filename="'+newid+'"]');
                }
                $(this).attr('filename', newid);
            });
            insertActions(newElm);
            setContextMenu(newElm);
            dlg.dialog("close");
        });
        
    });
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
                $( this ).dialog( "close" );
            }
        }
    });
}