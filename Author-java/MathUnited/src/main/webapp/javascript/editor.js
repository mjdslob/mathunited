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

requirejs.config({
    //By default load any module IDs from js/lib
    baseUrl: '/MathUnited/javascript/lib',
//    baseUrl: 'js/lib',
    //except, if the module ID starts with "app",
    //load it from the js/app directory. paths
    //config is relative to the baseUrl, and
    //never includes a ".js" extension since
    //the paths config could be for a directory.
    paths: {
        app: '../editor',
        actions: '../editor/actions',
        jquery: 'jquery-ui-1.10.3/jquery-1.9.1', //change here when using newer version of jquery,
        jqueryui: 'jquery-ui-1.10.3/ui/minified/jquery-ui.min', //change here when using newer version of jquery,
        touchpunch: 'jquery.ui.touch-punch.min',
        tinymce: '../tinymce/jquery.tinymce.min'
        
    },
    shim: {
        'jqueryui': {
            deps: ['jquery'],
            export: 'jqueryui'
        },
        'touchpunch': {
            deps: ['jqueryui'],
            export: 'touchpunch'
        },
        'tinymce': {
            deps: [],
            export: 'tinymce'
        }
    }
});

// Start the main app logic.
requirejs(['jquery', 'app/Main','touchpunch'],
function   ($, Main,touchpunch) {
    Main.init();
/*
    try{
        Main.init();
    } catch(err) {
        alert(err.message);
    }
*/    
});

