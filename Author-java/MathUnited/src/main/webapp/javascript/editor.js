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
    urlArgs: "bust=20160310", //update this when a modification is made, to prevent caching problems
    //By default load any module IDs from js/lib
    baseUrl: "/MathUnited/javascript/lib",
//    baseUrl: 'js/lib',
    //except, if the module ID starts with "app",
    //load it from the js/app directory. paths
    //config is relative to the baseUrl, and
    //never includes a ".js" extension since
    //the paths config could be for a directory.
    paths: {
        app: '../editor',
        actions: '../editor/actions',
        akitex: '../editor/akit_ex',
        akit: '../editor/algebrakit/akit',
        trainer: '../editor/algebrakit/trainer',
        exercise: '../editor/algebrakit/exercise',
        jquery: 'jquery-1.10.2', //change here when using newer version of jquery,
        jqueryui: 'jquery-ui-1.10.4.custom.min', //change here when using newer version of jquery,
        jqueryChosen: 'chosen_v1.1.0/chosen.jquery.min',
//        touchpunch: 'jquery.ui.touch-punch.min',
        tinymce: '../tinymce/jquery.tinymce.min',
        mathjax: "https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AM_CHTML&amp;delayStartupUntil=configured",
        touchpunch: 'jquery.ui.touch-punch.min'
        
    },
    shim: {
        'mathquill': {
            deps: ['jquery','../lib/mathquill'],
            exports: 'mathquill'
        },
        'jqueryui': {
            deps: ['jquery'],
            export: '$'
        },
        'touchpunch': {
            deps: ['jqueryui'],
            export: 'touchpunch'
        },
        'jqueryChosen': {
            deps: ['jquery']
        },
/*        
        'touchpunch': {
            deps: ['jqueryui'],
            export: 'touchpunch'
        },
*/        
        'tinymce': {
            deps: [],
            export: 'tinymce'
        },
        mathjax: {
            exports: "MathJax",
            init: function () {
              MathJax.Hub.Config({ 
                    extensions: ["mml2jax.js","asciimath2jax.js"],
                    config : ["MMLorHTML.js" ],
                    AsciiMath: {
                    decimal: ","
                    },
                    jax: ["input/MathML","input/AsciiMath"]
              });
              return MathJax;
            }
        }
    }
});

// Start the main app logic.
requirejs(['jquery', 'app/Main', 'mathjax'],
function   ($, Main, MathJax) {
   $( function(){
       Main.init(); 
   } );
});

