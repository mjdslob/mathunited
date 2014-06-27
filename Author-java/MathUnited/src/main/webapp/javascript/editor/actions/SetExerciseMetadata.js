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

    function itemText(item) {
        // Make descriptive display text from a reference
        return [item.thread, item.component, item.subcomponent, item.item].map(function (el) {
            return $('<div/>').text(el.name).html();
        }).join(" &raquo; ");
    }

    function References(container) {
        this.refs = [];
        this.container = container;
    }

    // Return index of reference of -1 if reference is present
    References.prototype.indexOf = function(thread, comp, subcomp, item) {
        for (var i = 0; i < this.refs.length; i++) {
            var cur = this.refs[i];
            if (cur.thread === thread && cur.comp === comp && cur.subcomp === subcomp && cur.item === item) {
                return i;
            }
        }
        return -1;
    };

    // Check if given reference is present
    References.prototype.has = function(thread, comp, subcomp, item) {
        return this.indexOf(thread, comp, subcomp, item) !== -1;
    };

    // Push current exercise's references to metadata section
    References.prototype.pushReferencesToMetadata = function() {
        // Remove old paragraph-ref's
        $('div[tag="paragraph-ref"]', this.container).remove();

        // Store references
        var metadata_data = $('div[tag="metadata"]', this.container);

        $.each(this.refs, function() {
            $('<div tag="paragraph-ref"></div>')
                .attr('thread', this.thread)
                .attr('comp', this.comp)
                .attr('subcomp', this.subcomp)
                .attr('item', this.item)
                .appendTo(metadata_data);
        });

        // Write empty div if there are no references
        if (this.refs.length === 0) {
            $('<div tag="paragraph-ref"></div>').appendTo(metadata_data);
        }
    };

    // Add a reference to the current exercise
    References.prototype.addReference = function(thread, comp, subcomp, item) {
        if (!this.has(thread, comp, subcomp, item)) {
            this.refs.push({thread:thread, comp:comp, subcomp:subcomp, item:item});
        }
    };

    // Add a reference to the current exercise
    References.prototype.enableReference = function(thread, comp, subcomp, item) {
        if (!this.has(thread, comp, subcomp, item)) {
            this.refs.push({thread:thread, comp:comp, subcomp:subcomp, item:item});
            this.pushReferencesToMetadata();
        }
    };

    // Remove a reference from the current exercise
    References.prototype.disableReference = function(thread, comp, subcomp, item) {
        var refid = this.indexOf(thread, comp, subcomp, item);
        if (refid != -1) {
            this.refs.splice(refid, 1);
            this.pushReferencesToMetadata();
        }
    };

    function makeDescription(container, references, item) {
        // We use narrow text to display the full name of the referenced paragraph
        var text = $("<span class='related-theory-text'/>").html(itemText(item));

        // HTML for buttons
        var ADD_TXT = '&nbsp;+&nbsp;';
        var DEL_TXT = '&nbsp;&times;&nbsp;';

        // Check if the item is in the current references
        var button_div, li_class;
        if (references.has(item.thread.id, item.component.id, item.subcomponent.id, item.item.id)) {
            button_div = '<div class="disable-item-button">' + DEL_TXT + '</div>';
            li_class = 'enabled-related-theory';
        } else {
            button_div = '<div class="enable-item-button">' + ADD_TXT + '</div>';
            li_class = 'disabled-related-theory';
        }

        // We will add a toggle button
        var button = $(button_div)
            .attr('thread', item.thread.id)
            .attr('comp', item.component.id)
            .attr('subcomp', item.subcomponent.id)
            .attr('item', item.item.id);

        // The remove button will remove the reference
        var toggle = function() {
            var li = button.parent();

            // Toggle between "remove" and "add"
            if (button.hasClass('disable-item-button')) {
                // Disable line and make into enable-item-button
                li.removeClass('enabled-related-theory').addClass('disabled-related-theory');
                button.removeClass('disable-item-button').addClass('enable-item-button');
                button.html(ADD_TXT);
                references.disableReference(button.attr('thread'), button.attr('comp'), button.attr('subcomp'), button.attr('item'));
            } else {
                // Disable line and make into enable-item-button
                li.removeClass('disabled-related-theory').addClass('enabled-related-theory');
                button.removeClass('enable-item-button').addClass('disable-item-button');
                button.html(DEL_TXT);
                references.enableReference(button.attr('thread'), button.attr('comp'), button.attr('subcomp'), button.attr('item'));
            }
        };
        button.click(toggle);

        // The entry consists of a the text and the button
        var entry = $('<li>').addClass(li_class).append(text).append(button);

        // We add it just in front of the add-item-button
        entry.insertBefore($(".related-theory li:last", container));
    }

     function setReferences(container) {
        var itemSelector = require('app/ItemSelector');

        // remove existing references before creating new ones
        $('ul.related-theory li.disabled-related-theory',container).remove();
        $('ul.related-theory li.enabled-related-theory',container).remove();
        
        // Get all references in exercises in document (and make sure we only include them once)
        var all_references = new References(null);

        $('div[tag="exercise"] div[tag="paragraph-ref"][thread][comp][subcomp][item]').each(function() {
            var el = $(this);
            var t = el.attr('thread'), c = el.attr('comp'), s = el.attr('subcomp'), item = el.attr('item');
            all_references.addReference(t, c, s, item);
        });

        // Get references of this exercise
        var references = new References(container);
        $('div[tag="paragraph-ref"][thread][comp][subcomp][item]', container).each(function() {
            var el = $(this);
            var t = el.attr('thread'), c = el.attr('comp'), s = el.attr('subcomp'), item = el.attr('item');
            references.enableReference(t, c, s, item);
        });

        // Make text entries
        $.each(all_references.refs, function () {
            itemSelector.getSelectedElements({
                    threadid: this.thread,
                    compid: this.comp,
                    subcompid: this.subcomp,
                    itemid: this.item},
                function (item) {
                    makeDescription(container, references, item);
                });
        });

        // Add a button to add additional references
        $('.add-item-button',container).click(function() {
            var current = null;
            var ref = references.refs.length > 0 ? references.refs[0] : (all_references.refs.length > 0 ? all_references.refs[0] : null);
            if (ref) {
                current= {
                    threadid: ref.thread,
                    compid: ref.comp,
                    subcompid: ref.subcomp,
                    itemid: ref.item
                };
            }
            itemSelector.show(current, function(result) {
                // Enable as reference
                references.enableReference(result.thread.id, result.component.id, result.subcomponent.id, result.item.id);

                // Add line as description
                makeDescription(container, references, result);

            });
        });

    }
    
    return {
        removeObjectiveFromDocument: function(id) {
            $('div[tag="objective-ref"][value="'+id+'"]').remove(); //remove tag (xml)
            $('.metadata-obj-selector-container input[value="'+id+'"]').nextUntil('input').remove();//remove from gui
            $('.metadata-obj-selector-container input[value="'+id+'"]').remove();
        },
        setExerciseIcons: function(parent) {
            var iconContainer = $('.exercise-icon-wrapper',parent).first();
            iconContainer.empty();
            //use stars to show difficulty-level.
            var elm = $('div[tag="level"]',parent).first();
            var level = 0;
            if(elm.length>0) level = parseInt(elm.attr('value'));
            for(var ii=0;ii<level;ii++) {
                iconContainer.append('<span class="level-star-icon"/>');
            }
        },
        action : function(elm, params) {
            var _this = this;
            //set the values (selections) in the metadata-frame. Changing values due to user clicks
            //is handled below in this function : $('form input',container).change(....)
            var doc = require('app/Document');
            var base = elm.parents('._editor_context_base').first();

            //container contains both the visual frame as the div with xml-tags
            var container = $('.metadata-container',base).first().addClass('visible');

            //tag contains the xml-tags : not visible but defines what is stored as xml
            var tag = $('*[tag="metadata"]',container).first();
            var objTagContainer = $('div[tag="objectives"]',container);
            if(objTagContainer.length===0) {
                objTagContainer = $('<div tag="objectives"></div>');
                tag.append(objTagContainer);
            }
            var is_examenvraag = $('div[tag="exercise-type"][value="examen"]',tag).length>0;
            var is_olympiadevraag = $('div[tag="exercise-type"][value="olympiade"]',tag).length>0;
            var is_wdavraag = $('div[tag="exercise-type"][value="wda"]',container).tag>0;
            $('form input[name="examenvraag"]', container)[0].checked = is_examenvraag;
            $('form input[name="olympiadevraag"]', container)[0].checked = is_olympiadevraag;
            $('form input[name="wda"]', container)[0].checked = is_wdavraag;
            var grouplabels='';
            $('div[tag="group-label"]',tag).each(function() {
               grouplabels += $(this).attr('value')+' '; 
            });
            $('form input[name="groepslabel"]', container).val(grouplabels);

            //difficulty level
            var level = $('div[tag="level"]',tag).attr('value');
            if(level) {
                var dum=$('form input[name="level"][value="'+level+'"]', container);
                if(dum.length>0) dum[0].checked= true;
            };
            //medium: web, paper, both or none. Not set in metadata, but as attribute on item
            var item = container.parents('div.included-item-wrapper').first();
            if(item.length>0){
                var medium = item.attr('medium');
                if(!medium) medium='both';
                var dum=$('form input[name="medium"][value="'+medium+'"]', container);
                if(dum.length>0) dum[0].checked= true;
            } else {
                $('.meta-medium',container).css('display','none');
            }
            var isClone = $('div[tag="clone"]',tag).attr('active');
            if(isClone==='true') {
                var dum=$('form input[name="kloonopgave"]', container);
                if(dum.length>0) dum[0].checked= true;
            };
            setReferences(container);

            //calculator allowed?
            var useCalc = true;  //default: calculator is 
            var calc = $('div[tag="calculator"][allowed="false"]',tag);
            if(calc.length>0) useCalc = false;
            var calcElm = $('form input[name="calculator_allowed"]',container);
            if(calcElm.length>0 && useCalc) calcElm[0].checked=true;
            
            //leerdoelen
            var main = require('app/Main');
            var objContainer = $('.metadata-obj-selector-container',container);
            var html='';
            
            objContainer.empty();
            function addObjective(elm){
                var objid = elm.attr('id');
                var parid = elm.attr('subcomp');
                var filter = '[subcomp="'+parid+'"]';
                if(!parid) {
                    parid = main.getSubcomp();
                    filter='';
                }
                var compid = elm.attr('comp');
                if(!compid) compid = main.getComp();
                var html;
                if($('div[tag="objective-ref"][value="'+objid+'"]'+filter,objTagContainer).length>0){
                    html='<input type="checkbox" name="objective" checked value="'+objid+'" comp="'+compid+'" subcomp="'+parid+'"><span class="objective-ref-text">'+elm.text()+'</span><br>'; 
                } else {
                    html='<input type="checkbox" name="objective" value="'+objid+'" comp="'+compid+'" subcomp="'+parid+'"><span class="objective-ref-text">'+elm.text()+'</span><br>'; 
                }
                objContainer.append( $(html) );
            }
            $('div[tag="description"] div[tag="objective"]').each(function() {
                addObjective($(this));
            });
            //in case of non-editable objectives (Totaalbeeld)
            $('div[tag="description"] div.objective-wrapper div.objective').each(function() {
                addObjective($(this));
            });

            //close button
            $('.close-metadata-button',container).click(function(){
                 $(this).parents(".metadata-container").first().removeClass('visible');
            });

            //helper function to set attributes/text on metadata-element. 
            //- tag: which metadata xml-element (e.g. level, exercise-type)
            //- attr/text: attributes or text to set
            //- doReplace: add element (false) or replace existing element (true)
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
                $('input[name="medium"]',container).each(function() {
                   if(this.checked) medium = this.value; 
                });
                $('input[name="calculator_allowed"]',container).each(function() {
                   if(!this.checked)  addMetadataElm(tag,'calculator', {allowed: 'false'},null,true);
                   else { $('div[tag="calculator"]',tag).remove(); }
                });
                item.attr('medium', medium);
//                var include = container.parents('div[tag]="include"').first();
//                var itemelm = include.children().first();
//                itemelm.attr('medium', medium);
                container.parents('div[tag="exercise"]').first().attr('medium',medium);
                var txt;
                switch(medium) {
                    case 'web': txt='web'; break;
                    case 'paper': txt='papier'; break;
                    case 'none': txt='verborgen'; break;
                    default: txt='';
                }
                $('div.block-button',item).first().text(txt);
                
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
                    txt = txt.replace('/\s{2,}/g',' ');
                    var elms = txt.split(' ');
                    for(var ii=0; ii < elms.length; ii++) {
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
 
                _this.setExerciseIcons(base);
            }); 
        }
    };
});