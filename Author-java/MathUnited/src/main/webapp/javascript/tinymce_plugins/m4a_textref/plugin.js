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
    tinymce.PluginManager.requireLangPack('m4a_textref');

    tinymce.create('tinymce.plugins.M4A_textrefPlugin', {
        /**
         * Initializes the plugin, this will be executed after the plugin has been created.
         * This call is done before the editor instance has finished it's initialization so use the onInit event
         * of the editor instance to intercept that event.
         *
         * @param {tinymce.Editor} ed Editor instance that the plugin is initialized in.
         * @param {string} url Absolute URL to where the plugin is located.
         */
        init: function (ed, url) {
            if (ed.settings.content_css !== false)
                ed.contentCSS.push(url + '/css/content.css');

            function showDialog() {
                var data = {text: '', id: ''};
                var ed = tinymce.activeEditor;
                var node = ed.selection.getNode();
                data.text = $('<span>' + ed.selection.getContent() + '</span>').text();
                if (node.nodeName == 'SPAN' && $(node).attr('class') == 'textref') {
                    data.text = $(node).text();
                    data.id = $(node).attr('ref');
                    ed.selection.select(node);
                }
                var win = ed.windowManager.open({
                    title: "Referentie invoegen",
                    width: 500,
                    height: 200,
                    inline: 1,
                    data: data,
                    body: [
                        {
                            name: 'Tekst', type: 'textbox', size: 40, label: 'Tekst: ', value: data.text,
                            onchange: function () {
                                data.text = this.value();
                            }
                        },
                        {
                            name: 'Ref', type: 'textbox', size: 40, label: 'Referentie: ', value: data.id,
                            onchange: function () {
                                data.id = this.value();
                            }
                        }
                    ],
                    buttons: [
                        {
                            text: "OK", onclick: function () {
                            ed.selection.setContent(" <span class='textref' ref='" + data.id + "'>" + data.text + "</span>");
//                                        ed.execCommand('mceInsertContent', false, " <span class='textref' ref='"+data.id+"'>"+data.text+"</span>");
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
            ed.addButton('m4a_textref', {
                title: 'Verwijzing',
                onclick: showDialog,
                image: url + '/img/example.gif',
                stateSelector: 'span[class="textref"]'
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
                longname: 'Textref plugin',
                author: 'Martijn Slob, Math4All',
                authorurl: 'http://math4all.nl',
                infourl: 'http://math4all.nl',
                version: "1.0"
            };
        }
    });

    // Register plugin
    tinymce.PluginManager.add('m4a_textref', tinymce.plugins.M4A_textrefPlugin);
})();