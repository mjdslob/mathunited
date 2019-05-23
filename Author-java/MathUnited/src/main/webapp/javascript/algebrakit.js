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
    baseUrl: 'javascript/lib',
//    baseUrl: 'js/lib',
    //except, if the module ID starts with "app",
    //load it from the js/app directory. paths
    //config is relative to the baseUrl, and
    //never includes a ".js" extension since
    //the paths config could be for a directory.
    paths: {
        akitex: '../editor/akit_ex',
        akit: '../algebrakit',
        jquery: 'jquery-ui-1.12.1.custom/external/jquery/jquery', //change here when using newer version of jquery,
        jqueryui: 'jquery-ui-1.12.1.custom/jquery-ui.min', //change here when using newer version of jquery,
        //mathjax: "../../bower_components/MathJax/MathJax.js?config=TeX-AMS_HTML&amp;delayStartupUntil=configured",
        mathjax: "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS_CHTML&amp;delayStartupUntil=configured",
    },
    shim: {
        'mathquill': {
            deps: ['jquery','../lib/mathquill'],
            exports: 'mathquill'
        },
        'jqueryui': {
            deps: ['jquery'],
            export: 'jqueryui'
        },
        mathjax: {
            exports: "MathJax",
            init: function () {
              MathJax.Hub.Config({ 
                    extensions: ["mml2jax.js","asciimath2jax.js"],
                    config : ["MMLorHTML.js" ],
                    AsciiMath: {
//                    decimal: "," //interferes with english versions
                    },
                    jax: ["input/MathML","input/AsciiMath"]
              });
              return MathJax;
            }
        }
    }
});

// Start the main app logic.
requirejs(['jquery', 'akit/trainer/Main','mathjax'],
function   ($,Trainer) {
    /*
    $('.akit-exercise').each(function() {
        try{
            Main.addExercise({
                dom: this
            });
        } catch(err) {
            alert(err.message);
        }
    });
    */
    $('m4a-trainer').each(function() {
        try{
            Trainer.init({
                dom: $(this),
                exerciseId: $(this).attr('exercise-id')
            });
        } catch(err) {
            alert(err.message);
        }        
    });
});

