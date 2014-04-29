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

define(['jquery'], function($, objSelector) {
    var container = null; //contains metadata elements, both visual representation and xml-tags
    
    function setReferences() {
        //gerelateerde theorie
        //var parRef = $('div[tag="paragraph-ref"]',container).attr('value');
        //$('form input[name="ref-id"]', container).val(parRef);
        var ref = $('div[tag="paragraph-ref"]', container);
        if(ref.length>0) {
            var threadid = ref.attr('thread');
            var compid = ref.attr('comp');
            var subid = ref.attr('subcomp');
            var itemid = ref.attr('item');
            var itemSelector = require('app/ItemSelector');
            itemSelector.getSelectedElements({threadid: threadid, compid: compid, subcompid:subid, itemid:itemid}, function(result) {
                var descr=result.thread.name+' >> '+result.component.name+' >> '+result.subcomponent.name+' >> '+result.item.name;
                $('.related-theory',container).text(descr);
            });
        }
        $('.select-item-button',container).click(function() {
            var itemSelector = require('app/ItemSelector');
            var current = null;
            if(compid) current={threadid: threadid, compid:compid, subcompid:subid, itemid:itemid};
            itemSelector.show(current,function(result) {
                var ref=result.thread.name+' >> '+result.component.name+' >> '+result.subcomponent.name+' >> '+result.item.name;
                $('.related-theory',container).text(ref);
                $('div[tag="paragraph-ref"]',container).remove();
                $('<div tag="paragraph-ref"></div>').appendTo($('.metadata-data',container))
                        .attr('thread',result.thread.id)
                        .attr('comp',result.component.id)
                        .attr('subcomp',result.subcomponent.id)
                        .attr('item', result.item.id);
            });
        });
        
    }
    
    return {
        removeObjectiveFromDocument: function(id) {
            $('div[tag="objective-ref"][value="'+id+'"]').remove(); //remove tag (xml)
            $('.metadata-obj-selector-container input[value="'+id+'"]').nextUntil('input').remove();//remove from gui
            $('.metadata-obj-selector-container input[value="'+id+'"]').remove();
        },
        action : function(elm, params) {
            var doc = require('app/Document');
            var base = elm.parents('._editor_context_base').first();
            container = $('.metadata-container',base).first().addClass('visible');
            var tag = $('*[tag="metadata"]',container).first();
            var objTagContainer = $('div[tag="objectives"]',container);
            if(objTagContainer.length===0) {
                objTagContainer = $('<div tag="objectives"></div>');
                tag.append(objTagContainer);
            }
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

            if(level) {
                var dum=$('form input[name="level"][value="'+level+'"]', container);
                if(dum.length>0) dum[0].checked= true;
            };
            var isClone = $('div[tag="clone"]',container).attr('active');
            if(isClone==='true') {
                var dum=$('form input[name="kloonopgave"]', container);
                if(dum.length>0) dum[0].checked= true;
            };
            
            setReferences();
            //leerdoelen
            var main = require('app/Main');
            var objContainer = $('.metadata-obj-selector-container',container);
            var html='';
            $('div[tag="description"] div[tag="objective"]').each(function() {
                var objid = $(this).attr('id');
                var parid = main.getSubcomp();
                var compid = main.getComp();
                if($('div[tag="objective-ref"][value="'+objid+'"]',objTagContainer).length>0){
                    html+='<input type="checkbox" name="objective" checked value="'+objid+'" comp="'+compid+'" subcomp="'+parid+'"><span class="objective-ref-text">'+$(this).text()+'</span><br>'; 
                } else {
                    html+='<input type="checkbox" name="objective" value="'+objid+'" comp="'+compid+'" subcomp="'+parid+'"><span class="objective-ref-text">'+$(this).text()+'</span><br>'; 
                }
            });
            html = $(html);
            objContainer.empty();
            objContainer.append(html);

            //close button
            $('.close-metadata-button').click(function(){
                 $(this).parents(".metadata-container").first().removeClass('visible');
            });

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
                doc.setChanged(true);
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
                
                objTagContainer.empty();
                $('input[name="objective"]:checked',container).each(function(){ 
                    addMetadataElm(objTagContainer, 'objective-ref',{value: this.value, comp: $(this).attr('comp'), subcomp: $(this).attr('subcomp')}, null,false);
                });
            }); 
        }
    };
});