/* 
 * Copyright (C) 2013 Martijn Slob <m.slob@math4all.nl>, Bas van der Linden <bas.linden@gmail.com>
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

define(['jquery','mathjax','app/AlgebraKITSpecHandler'], function($, MathJax, AlgebraKITSpecHandler) {
    
    return {
        action : function(elm, params) {

            // Get parent of multi-item
            var multi_item = elm.closest('div[tag="multi-item"]');

            // Get all non-algebrakit items
            var items = multi_item.find('div[tag="item"][type!="algebrakit"]');

            // Get item labels
            var labels = items.map(function(){return $(this).attr("label");}).get();

            // We can stop immediately if there are no labels to change
            if (labels.length == 0) {
                console.log("There were no non-AKIT items.");
                return;
            }

            // Get item-container that encloses the exercise
            var parent = elm.closest('.item-container', multi_item);

            // Remove editors first (we cannot copy tinymce, because id's need to be unique)
            var tinymce = require('app/TinyMCE');
            $('div.tiny-editor',parent).each(function() {
                //var thisElm = $(this);
                tinymce.remove($(this));
            });

            // Remove numbers and menu ids in this part
            $('._editor_context_base',parent).removeAttr('num');
            $('.contextMenu',parent).remove();
            $('._editor_option',parent).removeAttr('id');

            // Prepare for submission
            var doc = require('app/Document');
            doc.prepareForSubmit(parent);

            // Adjust current exercise by changing type and adding evaluation tag to each item...
            var generator = require('app/DOMgenerator');
            generator.getXML(parent[0], function(xml) {
                xml = $(xml);

                // Process all labels
                for (var i = 0; i < labels.length; i++) {
                    // Change exercise with this label
                    var label = labels[i];
                    console.log('Setting item "' + label + '" to AKIT.');

                    // Find item back
                    var xml_item = $('item[label="' + label + '"]', xml);

                    // Change type
                    xml_item.attr('type', 'algebrakit');

                    // Insert evaluation tag with empty answer if it is missing
                    if (xml_item.children('evaluation').length == 0) {
                        // Look for audience on page
                        var all_evaluations = $('div[tag="evaluation"][audience]', document);
                        var audience = all_evaluations.length > 0 ? all_evaluations.first().attr("audience") : "vwo-b";
                        var eval = $("<evaluation/>")
                            .attr("audience", audience)
                            .attr("solve", "");
                        eval.appendTo(xml_item);
                    }
                }

                // Make roundtrip to server
                generator.convertXML(xml, function(elm) {
                    parent.replaceWith(elm);
                    doc.setChanged(true);
                    doc.reinit(elm);
                    MathJax.Hub.Queue(["Typeset", MathJax.Hub, elm[0]]);
                    AlgebraKITSpecHandler.init();
                });
            });

        }
    };
});