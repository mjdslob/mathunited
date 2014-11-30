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

define(['akitex/Main','jquery'], function(AKITMain, $) {

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
                    if (name == "solve") {
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
                
                
                $('.algebrakit-test-config',parent).first().click(function() {
                    var str = '<div class="akit-exercise akit-init-open" audience="">'
                            + '  <div class="akit-main akit-item">'
                            + '     <span class="akit-input-widget" solve=""/>'
                            + '  </div>'
                            + '</div>';
                    var elm = $(str);
                    var inp = $('.akit-input-widget',elm);
                    str = $('select.audience-select option:selected', parent).attr('value');
                    elm.attr('audience',str);
                    str = $('select.item-palette-select option:selected', parent).attr('value');
                    if(str && str!=='default')  elm.attr('palette',str);
                    inp.attr('solve',$('input[name="solve"]', parent).val().trim());
                    str = $('select.algebrakit-mode-select option:selected', parent).attr('value');
                    inp.attr('mode',str);
                    str = $('select.algebrakit-hint-select option:selected', parent).attr('value');
                    if(str==='false')  elm.attr('show-hints',str);
                    
                    str = $('input[name="submit"]', parent).val().trim();
                    if(str) inp.attr('submit',str);
                    str = $('input[name="answer"]', parent).val().trim();
                    if(str) inp.attr('answer',str);
                    str = $('input[name="solution-attributes"]', parent).val().trim();
                    if(str) inp.attr('solution-attributes',str);
                    str = $('input[name="question"]', parent).val().trim();
                    if(str) {
                        inp.append($('<div class="akit-input-label">'+str+'</div>'));
                    }
                    
                    str = $('input[name="submit"]', parent).val().trim();
                    if(str) inp.attr('submit',str);
                    var dlg = elm.dialog({
                        resizable: true,
                        height:400,
                        width:800,
                        modal: false,
                        buttons: {
                            Cancel: function() {
                                $( this ).dialog( "close" );
                            }
                        }
                    });
                    
                    AKITMain.addExercise({dom:dlg});
                });
            });
            
            
        },
        action : function(elm, params) {  }
    };
});