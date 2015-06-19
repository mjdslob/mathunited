/* 
 * Copyright (C) 2013 AlgebraKIT <info@algebrakit.nl>
 *
 */

//This is a stub for the actual AlgebraKIT-engine which runs on the server.
define(['jquery', 'akitex/Exercise', 'akitex/Util', 'mathquill', 'mathjax', 'jqueryui'], function ($, Exercise, Util, mathquill) {
    MathJax.Hub.Startup.onload();
    var idCounter = 0;

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

    return {
        isTouchDevice: function () {
            return false;
        }, // Util.isEventSupported("touchstart");},
        exercises: [],
        /** the Exercise that is receiving input */
        activeExercise: null,
        //spec:
        // - dom: $('.akit-exercise')
        // - onFinished: callback
        addExercise: function (spec) {
            var ex = new Exercise({id: idCounter, dom: spec.dom, onFinished: spec.onFinished});
            idCounter += 1;
            this.exercises.push(ex);
            ex.init();
            return ex;
        },
        setActiveExercise: function (ex) {
            if (this.activeExercise) {
                if (ex.id === this.activeExercise.id)
                    return;
                this.activeExercise.setInactive();
            }
            this.activeExercise = ex;
        }
    };
}
);



