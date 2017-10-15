/* 
 * Copyright (C) 2013 AlgebraKIT <info@algebrakit.nl>
 *
 */

//This is a stub for the actual AlgebraKIT-engine which runs on the server.
define(['jquery', 'akit/Util', 'trainer/View', 'akit/Engine', 'mathjax', 'jqueryui'], function ($,Util, View, Engine) {
//    MathJax = require('mathjax');

    MathJax.Hub.Startup.onload();

    //utility plugin to prevent automatic zooming on double tap on iPhone
    //note: does not work on Android (unless using Chrome)!
    (function ($) {
        $.fn.nodoubletapzoom = function () {
            $(this).bind('touchstart', function preventZoom(e) {
                var fingers = e.originalEvent.touches.length;
                if (fingers > 1)
                    return; // not double-tap

                e.preventDefault(); // double tap - prevent the zoom
                // also synthesize click events we just swallowed up
                $(this).trigger('click');
            });
        };
    })($);

    function startAssignmentFromPath(path, audience, dom) {
        Engine.selectAssignmentFromPath(path, audience)
                .done(function (asm) {
                    View.init({
                        dom: dom,
                        assignment: asm.assignment,
                        solveHandler: function () {
//                            Engine.processExpression('(3/4)/(3/2)', audience, null)
                            Engine.processExpression(asm.solve, audience, null)
                                    .done(function (step) {
                                        View.setOutput(step);
                                    });
                        },
                        repeatHandler: function () {
                            dom.html('');
                            startAssignment(path, audience, dom);
                        }
                    });
                });
    }
    return {
        isTouchDevice: function () {
            return false;
        }, // Util.isEventSupported("touchstart");},

        //spec:
        // .audience
        // .path
        // .dom : jquery of root node
        init: function(spec) {
            if(spec.path) {
                startAssignmentFromPath(spec.path, spec.audience, spec.dom);
            }
        },
        showDerivation: function(spec) {
            Engine.processExpression(spec.solve, spec.audience, spec.attributes)
                .done(function (step) {
                    View.showDerivation({
                        dom: spec.dom,
                        wkstep: step
                    });
                });
            }
    };
}
);


