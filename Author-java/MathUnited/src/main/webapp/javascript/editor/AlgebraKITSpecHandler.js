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

define(['exercise/Main','trainer/Main','jquery'], function(AKITExercise, AKITTrainer, $) {

    return {
        init: function(root) {            
            $('.algebrakit-spec-wrapper',root).each(function() {
                var parent = $(this);
                var tag = $('div[tag="evaluation"]', parent);


                // Callbacks on all input fields
                $('input', parent).change(function() {
                    var elm = $(this);
                    var name = elm.attr('name');
                    var val = $.trim(elm.val());

                    // Compulsory fields
                    if (name === "solve") {
                        if (!val) {
                            elm.addClass('wrong-input-line');
                        } else {
                            elm.removeClass('wrong-input-line');
                        }
                        tag.attr(name, val);
                    } else {
                        // Optional input fiels are removed if empty
                        if (!val) {
                            tag.removeAttr(name, val);
                        } else {
                            tag.attr(name, val);
                        }
                    }
                });

                function chooseSelectedItem(classname, target, attrname, defval, remove) {
                    // Get <select> element of specified class
                    var sel = $('select.' + classname, parent);

                    // Set the current value of the target if it is present, default value otherwise
                    sel.val(target.is('[' + attrname + ']') ? target.attr(attrname) : defval);

                    // Callback function
                    sel.change(function () {
                        // Get the value
                        var option = $('option:selected', $(this));
                        var value = option.attr('value');

                        // Remove tag if it is equal to the default
                        if (remove && value == defval) {
                            target.removeAttr(attrname)
                        } else {
                            // Set value
                            target.attr(attrname, value);
                        }
                    });
                };

                // Change 'audience' tag on <evaluation>
                chooseSelectedItem('audience-select', tag, 'audience', 'vwo-b', false);

                // Change 'palette' tag on parent <item>
                var item = tag.closest('div[tag="item"]');
                chooseSelectedItem('item-palette-select', item, 'palette', 'default', true);

                // Change 'mode' tag on <evaluation>
                chooseSelectedItem('algebrakit-mode-select', tag, 'mode', 'EQUIVALENT', true);

                // Change 'show-hints' tag on <evaluation>
                chooseSelectedItem('algebrakit-hint-select', tag, 'show-hints', 'true', true);
                
                
                $('.algebrakit-test-config',parent).first().unbind('click').click(function() {
                    var str = '<div class="akit-dialog">' 
                            + '  <div class="akit-exercise akit-init-open" audience="">'
                            + '    <div class="akit-main akit-item">'
                            + '       <span class="akit-input-widget" solve=""/>'
                            + '    </div>'
                            + '  </div>'
                            + '  <div style="clear:both"><h3>Uitwerking</h3></div>'
                            + '  <div class="akit-trainer" style="clear:both" solve="" attributes="" audience="">'
                            + '  </div>'
                            + '</div>';
                    var elm = $(str);
                    var exerciseElm = $('.akit-exercise',elm).first();
                    var trainerElm = $('.akit-trainer', elm).first();
                    var inp = $('.akit-input-widget',exerciseElm);
                    var audienceStr = $('select.audience-select option:selected', parent).attr('value');
                    exerciseElm.attr('audience',audienceStr);
                    trainerElm.attr('audience', audienceStr);
                    str = $('select.item-palette-select option:selected', parent).attr('value');
                    if(str && str!=='default')  elm.attr('palette',str);
                    var solveExp = $('input[name="solve"]', parent).val().trim();
                    inp.attr('solve',solveExp);
                    trainerElm.attr('solve', solveExp);
                    str = $('select.algebrakit-mode-select option:selected', parent).attr('value');
                    inp.attr('mode',str);
                    str = $('select.algebrakit-hint-select option:selected', parent).attr('value');
                    if(str==='false')  exerciseElm.attr('show-hints',str);
                    
                    str = $('input[name="submit"]', parent).val().trim();
                    if(str) inp.attr('submit',str);
                    str = $('input[name="answer"]', parent).val().trim();
                    if(str) inp.attr('answer',str);
                    var attributesStr = $('input[name="solution-attributes"]', parent).val().trim();
                    if(attributesStr) inp.attr('solution-attributes',attributesStr);
                    if(attributesStr) trainerElm.attr('attributes', attributesStr);
                    str = $('input[name="question"]', parent).val().trim();
                    if(str) {
                        inp.append($('<div class="akit-input-label">'+str+'</div>'));
                    }
                    
                    str = $('input[name="submit"]', parent).val().trim();
                    if(str) inp.attr('submit',str);
                    var dlg = elm.dialog({
                        resizable: true,
                        height:600,
                        width:800,
                        modal: false,
                        dialogClass: 'akit-dialog',
                        buttons: {
                            Cancel: function() {
                                $( this ).dialog( "close" );
                            }
                        }
                    });
                    AKITExercise.addExercise({dom:$('.akit-exercise',dlg).first()});
                    AKITTrainer.showDerivation({
                        dom: trainerElm,
                        audience: audienceStr,
                        solve: solveExp,
                        attributes: attributesStr
                    });
                });
            });
            
            
        },
        action : function(elm, params) {  }
    };
});