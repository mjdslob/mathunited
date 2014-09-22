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

    return {
        init: function() {            
            $('.algebrakit-spec-wrapper').each(function() {
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
                chooseSelectedItem('algebrakit-mode-select', tag, 'mode', 'EXACT', true);

                // Change 'show-hints' tag on <evaluation>
                chooseSelectedItem('algebrakit-hint-select', tag, 'show-hints', 'true', true);
            });
            
        },
        action : function(elm, params) {  }
    };
});