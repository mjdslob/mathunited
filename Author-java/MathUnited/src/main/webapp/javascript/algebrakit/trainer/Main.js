/* 
 * Copyright (C) 2013 AlgebraKIT <info@algebrakit.nl>
 *
 */

//This is a stub for the actual AlgebraKIT-engine which runs on the server.
define(['jquery', 'akit/Factory', 'akit/trainer/View', 'mathjax', 'jqueryui'], function ($, Factory, View) {

    function solve(exerciseSpec) {
        
    }
    
    function repeatAssignment(exerciseId, view) {
        Factory.generate(exerciseId, function(resp){
            View.repeat({
                view: resp.view,
                exerciseSpec: resp.exerciseSpec,
                solveHandler: function () {
                    solve(resp.spec);
                }
            });
        });
    }
    
    function createAssignmentFromId(exerciseId, dom) {
        Factory.generate(exerciseId, function(resp){
            View.init({
                dom: dom,
                view: resp.view,
                exerciseSpec: resp.exerciseSpec,
                solveHandler: function () {
                    solve(resp.spec);
                },
                repeatHandler: function () {
                    repeatAssignment(exerciseId);
                }
            });
        });
    }
    return {
        //spec:
        // .exerciseId
        // .dom : jquery of root node
        init: function(spec) {
            if(spec.exerciseId) {
                createAssignmentFromId(spec.exerciseId, spec.dom);
            }
        }
    };
}
);





