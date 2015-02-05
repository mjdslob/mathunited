/**
 * editor_plugin_src.js
 *
 * Copyright 2009, Moxiecode Systems AB
 * Released under LGPL License.
 *
 * License: http://tinymce.moxiecode.com/license
 * Contributing: http://tinymce.moxiecode.com/contributing
 */

(function () {

    // Load plugin specific language pack
    //tinymce.PluginManager.requireLangPack('m4a_cloze');

    tinymce.create('tinymce.plugins.M4A_clozePlugin', {
        /**
         * Initializes the plugin, this will be executed after the plugin has been created.
         * This call is done before the editor instance has finished it's initialization so use the onInit event
         * of the editor instance to intercept that event.
         *
         * @param {tinymce.Editor} ed Editor instance that the plugin is initialized in.
         * @param {string} url Absolute URL to where the plugin is located.
         */
        init: function (ed, url) {
            if (ed.settings.content_css !== false) {
                ed.contentCSS.push(url + '/css/content.css');
            }

            function showDialog() {
                // Number of cloze-answers supported
                var i, Nextra = 4;

                // Initialize cloze information
                var cloze = {
                    audience: '',
                    type: 'text',
                    hint: '',
                    palette: '',
                    answers: []
                };

                // Fill with existing values
                var ed = tinymce.activeEditor;
                var node = $(ed.selection.getNode()).closest('[tag="cloze"]');

                cloze.audience = node.attr('audience') || "";
                cloze.type = node.attr('type') || "";
                cloze.palette = node.attr('palette') || "";
                cloze.hint =  $('[tag="cloze-hint"]', node).first().html() || "";

                // Find the existing answers
                i = 0;
                $('[tag="cloze-answer"]', node).each(function (idx,elt) {
                    ++i;
                    console.log("I = " + i + ", idx = " + idx);
                    cloze.answers[idx] = {
                        text: $('[tag="cloze-answertext"]', elt).html() || "",
                        correction: $('[tag="cloze-correction"]', elt).html() || "",
                        evaluate: $(elt).attr("evaluate") || "equivalent",
                        score: $(elt).attr("score") || "100"
                    };
                });

                // Add answers plus a few
                for (i = 0; i < Nextra; i++) {
                    cloze.answers.push({
                        text: '',
                        correction: '',
                        evaluate: 'equivalent',
                        score: '100'
                    });
                }

                // Make selection
                ed.selection.select(node[0]);


                // Create body
                var body = [];
                var Nchar = 40;
                var typevals = [
                    {text: "Tekst", value: "text"},
                    {text: "AlgebraKit", value: "algebrakit" }
                ];
                var evalvals = [
                    {text: "Equivalent", value: "equivalent"},
                    {text: "Exact", value: "exact" }
                ];


                // Shortcut for making callbacks
                function make_cb(field) {
                    return function() { cloze[field] = ("" + this.value()).trim(); }
                }

                // Create call back functions to evaluate index on creation point
                function make_answer_cb(i, field) {
                    return function() { cloze.answers[i][field] = ("" + this.value()).trim(); }
                }


                // Some helper functions for repeated tasks

                function make_label(label) {
                    body.push({type: 'label', text: label, style: "font-weight: bold;" });
                }

                function make_textbox(field, label) {
                    body.push({ type: 'textbox', size: Nchar, label: label, value: "" + cloze[field], onchange: make_cb(field) });
                }

                function make_listbox(field, label, values) {
                    body.push({type: 'listbox', size: Nchar, label: label, value: "" + cloze[field], values: values, onchange: make_cb(field) });
                }

                function make_textbox_answer(i, field, label) {
                    body.push({ type: 'textbox', size: Nchar, label: label, value: "" + cloze.answers[i][field], onchange: make_answer_cb(i, field)});
                }

                function make_listbox_answer(i, field, label, values) {
                    body.push({type: 'listbox', size: Nchar, label: label, value: "" + cloze.answers[i][field], values: values, onchange: make_answer_cb(i, field) });
                }


                // Create body

                make_textbox("audience", "Doelgroep");
                make_listbox("type", "Soort", typevals);
                make_textbox("palette", "Palette");
                make_textbox("hint", "Hint");


                for (i = 0; i < cloze.answers.length; i++) {
                    make_label('Cloze antwoord ' + (i+1));
                    make_textbox_answer(i, "text", "Antwoord");
                    make_textbox_answer(i, "correction", "Correctie");
                    make_textbox_answer(i, "score", "Score");
                    make_listbox_answer(i, "evaluate", "Evaluatie", evalvals);
                }


                var win = ed.windowManager.open({
                    title: "Cloze Edit Definiëren",
                    width: 640,
                    height: 480,
                    inline: 1,
                    autoScroll: true,
                    body: body,
                    buttons: [
                        {
                            text: "OK",
                            onclick: function () {
                                var elt;

                                // Main info
                                cloze.audience = node.attr('audience') || "";
                                cloze.type = node.attr('type') || "";
                                cloze.palette = node.attr('palette') || "";
                                cloze.hint =  $('[tag="cloze-hint"]', node).first().html() || "";

                                // Put information back into HTML
                                function span(tag) {
                                    return $('<span tag="' + tag + '" class="' + tag + '"></span>');
                                }
                                var new_node = span('cloze');
                                new_node.attr('type', cloze.type);

                                if (cloze.audience) {
                                    new_node.attr('audience', cloze.audience);
                                }
                                if (cloze.palette) {
                                    new_node.attr('palette', cloze.palette);
                                }
                                if (cloze.hint) {
                                    new_node.append(span("cloze-hint").text(cloze.hint));
                                }

                                // Add answers
                                var answers = span("cloze-answers");
                                new_node.append(answers);
                                for (var i = 0; i < cloze.answers.length; i++) {
                                    var answer = cloze.answers[i];
                                    // Add if either is non-empty
                                    if (answer.text || answer.correction) {
                                        elt = span("cloze-answer");
                                        elt.attr("evaluate", answer.evaluate);
                                        elt.attr("score", answer.score);
                                        elt.append(span("cloze-answertext").text(answer.text));
                                        if (answer.correction) {
                                            elt.append(span("cloze-correction").text(answer.correction));
                                        }
                                        answers.append(elt);
                                    }
                                }

                                console.log(new_node);
                                ed.selection.setContent(new_node[0].outerHTML);

                                win.close();
                            }
                        },
                        {
                            text: "Annuleren", onclick: function () {
                            win.close();
                        }
                        }
                    ]
                });

            }


            // Register example button
            ed.addButton('m4a_cloze', {
                title: 'Cloze Edit',
                onclick: showDialog,
                image: url + '/img/cloze.png',
                stateSelector: 'span[class="cloze"]'
            });
        },

        /**
         * Returns information about the plugin as a name/value array.
         * The current keys are longname, author, authorurl, infourl and version.
         *
         * @return {Object} Name/value array containing information about the plugin.
         */
        getInfo: function () {
            return {
                longname: 'Cloze plugin',
                author: 'Bas van der Linden, Math4All',
                authorurl: 'http://math4all.nl',
                infourl: 'http://math4all.nl',
                version: "1.0"
            };
        }
    });

    // Register plugin
    tinymce.PluginManager.add('m4a_cloze', tinymce.plugins.M4A_clozePlugin);
})();