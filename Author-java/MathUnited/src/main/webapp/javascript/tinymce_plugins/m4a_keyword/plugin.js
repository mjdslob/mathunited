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
	tinymce.PluginManager.requireLangPack('m4a_keyword');

	tinymce.create('tinymce.plugins.M4A_keywordPlugin', {
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
                    ed.addCommand('m4a_keyword', function() {
                        var node = ed.selection.getNode();
                        if(node.nodeName=='SPAN' && $(node).attr('tag')=='text' && $(node).parent().attr('tag')=='keyword'){
                            //this is already a keyword
                            var txt = $(node).text();
                            $(node).parent().replaceWith(txt);
                        } else {
                            var elm = $('<span>'+ed.selection.getContent()+'</span>').text();
                            ed.selection.setContent('<span tag="keyword"><span tag="text">'+elm+'</span></span>');
                        }
                    });

                    // Register example button
                    ed.addButton('m4a_keyword', {
                            title : 'Trefwoord',
                            cmd : 'm4a_keyword',
                            image : url + '/img/example.gif',
                            stateSelector: 'span[tag="keyword"]'
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
				longname : 'Keyword plugin',
				author : 'Martijn Slob, Math4All',
				authorurl : 'http://math4all.nl',
				infourl : 'http://math4all.nl',
				version : "1.0"
			};
		}
	});

	// Register plugin
	tinymce.PluginManager.add('m4a_keyword', tinymce.plugins.M4A_keywordPlugin);
})();