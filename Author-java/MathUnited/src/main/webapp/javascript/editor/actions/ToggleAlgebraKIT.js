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

            // Check that item type is 'open'
            var item = elm.closest('div[tag="item"]');
            var was_algebrakit = (item.attr('type') == 'algebrakit');
            var is_single_item = (item.parent('div[tag="single-item"]').length > 0);

            var doc = require('app/Document');
            var base = elm.closest('._editor_context_base');
            var parent = elm.closest('.item-container', base);

            // Remove editors first (we cannot copy tinymce, because id's need to be unique)
            var tinymce = require('app/TinyMCE');

            $('div.tiny-editor',parent).each(function() {
                //var thisElm = $(this);
                tinymce.remove($(this));
            });

            $('._editor_context_base',parent).removeAttr('num');
            $('.contextMenu',parent).remove();
            $('._editor_option',parent).removeAttr('id');

            // Get label
            var label = item.attr('label');

            // Prepare for submission
            doc.prepareForSubmit(parent);

            // Adjust current exercise by changing type and adding evaluation tag...
            var generator = require('app/DOMgenerator');
            generator.getXML(parent[0], function(xml) {
                xml = $(xml);

                // Find item back
                var xml_item;
                if (is_single_item) {
                    xml_item = $('item', xml).first();
                } else {
                    xml_item = $('item[label="' + label + '"]', xml);
                }

                // Change type to open or algebrakit
                if (was_algebrakit) {
                    xml_item.attr('type', 'open');
                    // Remove evaluation tag
                    $('evaluation', xml_item).remove();
                } else {
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
                    doc.reinit(base);
                    MathJax.Hub.Queue(["Typeset", MathJax.Hub, elm[0]]);
                    AlgebraKITSpecHandler.init();
                });
            });

        }
    };
});