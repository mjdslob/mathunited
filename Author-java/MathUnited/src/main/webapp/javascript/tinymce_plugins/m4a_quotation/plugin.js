/**
 * editor_plugin_src.js
 *
 * Copyright 2009, Moxiecode Systems AB
 * Released under LGPL License.
 *
 * License: http://tinymce.moxiecode.com/license
 * Contributing: http://tinymce.moxiecode.com/contributing
 */

(function() {
	// Load plugin specific language pack
	tinymce.PluginManager.requireLangPack('m4a_quotation');

	tinymce.create('tinymce.plugins.M4A_quotationPlugin', {
		/**
		 * Initializes the plugin, this will be executed after the plugin has been created.
		 * This call is done before the editor instance has finished it's initialization so use the onInit event
		 * of the editor instance to intercept that event.
		 *
		 * @param {tinymce.Editor} ed Editor instance that the plugin is initialized in.
		 * @param {string} url Absolute URL to where the plugin is located.
		 */
		init : function(ed, url) {
                    if (ed.settings.content_css !== false)
                        ed.contentCSS.push(url + '/css/content.css');

                    // Register the command so that it can be invoked by using tinyMCE.activeEditor.execCommand('mceExample');
                    ed.addCommand('m4a_quotation', function() {
                        var node = ed.selection.getNode();
                        if(node.nodeName=='SPAN' && $(node).attr('tag')=='quotation'){
                            //this is already a keyword
                            var txt = $(node).text();
                            $(node).replaceWith(txt);
                        } else {
                            var elm = $('<span>'+ed.selection.getContent()+'</span>').text();
                            ed.selection.setContent('<span tag="quotation">'+elm+'</span>');
                        }

                    });

                    // Register example button
                    ed.addButton('m4a_quotation', {
                            title : 'Plaats tekst tussen aanhalingstekens',
                            cmd : 'm4a_quotation',
                            image : url + '/img/example.gif',
                            stateSelector: 'span[tag="quotation"]'
                    });
		},


		/**
		 * Returns information about the plugin as a name/value array.
		 * The current keys are longname, author, authorurl, infourl and version.
		 *
		 * @return {Object} Name/value array containing information about the plugin.
		 */
		getInfo : function() {
			return {
				longname : 'Quotation plugin',
				author : 'Martijn Slob, Math4All',
				authorurl : 'http://math4all.nl',
				infourl : 'http://math4all.nl',
				version : "1.0"
			};
		}
	});

	// Register plugin
	tinymce.PluginManager.add('m4a_quotation', tinymce.plugins.M4A_quotationPlugin);
})();